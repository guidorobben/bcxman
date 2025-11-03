codeunit 78603 "BCX Translate Dispatcher"
{
    var
        CachedBCXTranslationSetup: Record "BCX Translation Setup";
        SetupLoaded: Boolean;

    procedure Translate(ProjectCode: Text[20]; SourceLang: Text[10]; TargetLang: Text[10]; TextToTranslate: Text[2048]): Text[2048]
    var
        BCXDeepLTranslate: Codeunit "BCX DeepL Translate";
        BCXGoogleTranslateRest: Codeunit "BCX Google Translate Rest";
        BCXGPTTranslateRest: Codeunit "BCX GPT Translate Rest";
    begin
        EnsureSetupLoaded();

        if CachedBCXTranslationSetup."Use OpenAI" then
            exit(BCXGPTTranslateRest.Translate(ProjectCode, SourceLang, TargetLang, TextToTranslate))
        else
            if CachedBCXTranslationSetup."Use DeepL" then
                exit(BCXDeepLTranslate.Translate(ProjectCode, SourceLang, TargetLang, TextToTranslate))
            else
                if CachedBCXTranslationSetup."Use Free Google Translate" then
                    exit(BCXGoogleTranslateRest.Translate(ProjectCode, SourceLang, TargetLang, TextToTranslate));
    end;

    procedure UseChatGPT(): Boolean
    begin
        EnsureSetupLoaded();
        exit(CachedBCXTranslationSetup."Use OpenAI");
    end;

    local procedure EnsureSetupLoaded()
    begin
        if SetupLoaded then
            exit;

        if not CachedBCXTranslationSetup.Get() then
            Error('Translation setup is missing.');

        SetupLoaded := true;
    end;
}
