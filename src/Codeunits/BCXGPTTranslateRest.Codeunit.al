codeunit 78602 "BCX GPT Translate Rest"
{
    procedure SendHttpRequestWithAuth(HttpMethod: Text[10]; Url: Text; Payload: Text; ContentType: Text; HeaderName: Text; HeaderValue: Text; var ResponseHttpResponseMessage: HttpResponseMessage)
    var
        RequestHttpClient: HttpClient;
        RequestHttpContent: HttpContent;
        RequestHeaders: HttpHeaders;
        RequestHttpRequestMessage: HttpRequestMessage;
    begin
        // Create request
        RequestHttpRequestMessage.SetRequestUri(Url);
        RequestHttpRequestMessage.Method := HttpMethod;

        RequestHttpRequestMessage.GetHeaders(RequestHeaders);
        if (HeaderName <> '') and not RequestHeaders.Contains(HeaderName) then
            RequestHeaders.Add(HeaderName, HeaderValue);

        if (ContentType <> '') and not RequestHeaders.Contains('Content-Type') then
            RequestHeaders.Add('Content-Type', ContentType);

        // Write body
        RequestHttpContent.WriteFrom(Payload);
        RequestHttpRequestMessage.Content := RequestHttpContent;

        // Send request
        if not RequestHttpClient.Send(RequestHttpRequestMessage, ResponseHttpResponseMessage) then
            Error('%1 request failed: %2', HttpMethod, Url);
    end;


    procedure ReadResponseAsText(ResponseHttpResponseMessage: HttpResponseMessage): Text
    var
        ResponseText: Text;
    begin
        ResponseHttpResponseMessage.Content().ReadAs(ResponseText);
        exit(ResponseText);
    end;

    local procedure UnprotectGlossaryTerms(var Text: Text[2048]): Text[2048]
    begin
#pragma warning disable AA0139
        Text := Text.Replace('__KEEP__', '');
        Text := Text.Replace('__/KEEP__', '');
#pragma warning restore AA0139
        exit(Text);
    end;

    // Main translation function
    procedure Translate(ProjectCode: Text[20]; inSourceLang: Text[10]; inTargetLang: Text[10]; inText: Text[4000]) outTransText: Text[2048]
    var
        BCXGenTranslationTerm: Record "BCX Gen. Translation Term";
        BCXTranslationSetup: Record "BCX Translation Setup";
        BCXTranslationTerm: Record "BCX Translation Term";
        TypeHelper: Codeunit "Type Helper";
        HttpClient: HttpClient;
        TranslateHttpContent: HttpContent;
        Headers: HttpHeaders;
        TranslateHttpRequestMessage: HttpRequestMessage;
        TranslateHttpResponseMessage: HttpResponseMessage;
        Messages: JsonArray;
        Payload: JsonObject;
        SystemMsg, UserMsg : JsonObject;
        Glossary: List of [Text];
        GlossaryTerms: Text;
        ResponseText: Text;
        SystemPrompt: Text;
        Term: Text;
    begin
        if (inSourceLang = inTargetLang) then begin
            outTransText := CopyStr(inText, 1, 2048);
            exit;
        end;
        if not BCXTranslationSetup.Get() then
            Error('Translation setup is missing.');
        if not BCXTranslationSetup."Use OpenAI" then
            Error('OpenAI translation is disabled in setup.');
        // Add General Translation Terms marked as pre-translation to glossary
        if (BCXGenTranslationTerm.FindSet()) then
            repeat
                if not BCXGenTranslationTerm."Apply Pre-Translation" then
                    continue; // Skip terms that are not marked for pre-translation
                GlossaryTerms += BCXGenTranslationTerm.Term + ', ';
                Glossary.Add(BCXGenTranslationTerm.Term);
            until BCXGenTranslationTerm.Next() = 0;
        BCXTranslationTerm.SetFilter("Project Code", '%1', ProjectCode);
        if (BCXTranslationTerm.FindSet()) then
            repeat
                if not BCXTranslationTerm."Apply Pre-Translation" then
                    continue; // Skip terms that are not marked for pre-translation
                GlossaryTerms += BCXTranslationTerm.Term + ', ';
                Glossary.Add(BCXTranslationTerm.Term);
            until BCXTranslationTerm.Next() = 0;
        SystemPrompt :=
          'You are a professional translator specializing in Microsoft Business Central ERP. ' +
          'Translate from English (US) to the language specified in the first line (ISO format, e.g., da-DK). ' +
          'Use terminology consistent with Microsoft ERP and business applications. ' +
          'Preserve all placeholders exactly as-is (e.g., %1, <x>, <x id="1">). ' +
          'Do not translate product or feature names: ' + GlossaryTerms + '. ' +
          'Return only the translated sentence. No explanations. ' +
          'Do not return the language name or ISO code. Do not repeat the language code.';

        // Prepare JSON body
        SystemMsg.Add('role', 'system');

        SystemMsg.Add('content', SystemPrompt);
        Messages.Add(SystemMsg);

        UserMsg.Add('role', 'user');

        foreach Term in Glossary do
#pragma warning disable AA0139
            inText := inText.Replace(Term, '__KEEP__' + Term + '__/KEEP__');
#pragma warning restore AA0139

        UserMsg.Add('content', inTargetLang + TypeHelper.NewLine() + inText);
        Messages.Add(UserMsg);

        Payload.Add('model', Format(BCXTranslationSetup."OpenAI Model"));
        Payload.Add('temperature', 0);
        Payload.Add('max_tokens', 256);
        Payload.Add('messages', Messages);

        // Set up request
        TranslateHttpRequestMessage.SetRequestUri('https://api.openai.com/v1/chat/completions');
        TranslateHttpRequestMessage.Method := 'POST';
        TranslateHttpRequestMessage.GetHeaders(Headers);
        Headers.TryAddWithoutValidation('Authorization', 'Bearer ' + BCXTranslationSetup."OpenAI API Key");

        TranslateHttpContent.WriteFrom(Format(Payload));
        TranslateHttpContent.GetHeaders(Headers); // reuse same Headers to avoid split issues
        Headers.Remove('Content-Type');
        Headers.TryAddWithoutValidation('Content-Type', 'application/json');
        TranslateHttpRequestMessage.Content := TranslateHttpContent;

        // Send and check
        if not HttpClient.Send(TranslateHttpRequestMessage, TranslateHttpResponseMessage) then
            Error('Failed to send request to OpenAI API.');

        if not TranslateHttpResponseMessage.IsSuccessStatusCode() then
            Error('OpenAI returned status %1: %2', TranslateHttpResponseMessage.HttpStatusCode(), TranslateHttpResponseMessage.ReasonPhrase());

        TranslateHttpResponseMessage.Content().ReadAs(ResponseText);
        outTransText := CopyStr(ParseTranslatedText(ResponseText), 1, 2048); // Prevent overflow
        outTransText := UnprotectGlossaryTerms(outTransText);
    end;

    local procedure ParseTranslatedText(JsonText: Text): Text
    var
        ChoicesArr: JsonArray;
        ChoiceObj: JsonObject;
        MsgObj: JsonObject;
        Obj: JsonObject;
        ChoicesTok: JsonToken;
        ChoiceTok: JsonToken;
        ContentTok: JsonToken;
        MsgTok: JsonToken;
        Tok: JsonToken;
        Result: Text;
    begin
        if not Tok.ReadFrom(JsonText) then
            Error('Failed to parse GPT response JSON.');

        Obj := Tok.AsObject();
        if not Obj.Get('choices', ChoicesTok) then
            Error('GPT response missing ''choices'' array.');

        ChoicesArr := ChoicesTok.AsArray();

        if ChoicesArr.Count() = 0 then
            Error('GPT response contained no choices.');

        ChoicesArr.Get(0, ChoiceTok);
        ChoiceObj := ChoiceTok.AsObject();

        if not ChoiceObj.Get('message', MsgTok) then
            Error('GPT response choice missing ''message''.');

        MsgObj := MsgTok.AsObject();
        if not MsgObj.Get('content', ContentTok) then
            Error('GPT response message missing ''content''.');

        Result := ContentTok.AsValue().AsText();
        exit(Result);
    end;





}
