codeunit 78605 "BCX Xliff Parser"
{
    Permissions =
        tabledata "BCX Base Translation Notes" = rim,
        tabledata "BCX Base Translation Target" = rim,
        tabledata "BCX Translation Note" = rim,
        tabledata "BCX Translation Project" = rm,
        tabledata "BCX Translation Source" = rim,
        tabledata "BCX Translation Target" = rim,
        tabledata Language = R;

    // Public entry points for the three import types the XMLPorts used to handle
    procedure ImportSourceFromStream(ProjectCode: Code[20]; FileName: Text; var InS: InStream)
    begin
        ParseAndInsert(ProjectCode, FileName, InS, 'Source', '', '');
    end;

    procedure ImportBaseTargetFromStream(ProjectCode: Code[20]; SourceLangISO: Text[10]; TargetLangISO: Text[10]; FileName: Text; var InS: InStream)
    begin
        ParseAndInsert(ProjectCode, FileName, InS, 'BaseTarget', SourceLangISO, TargetLangISO);
    end;

    procedure ImportTargetFromStream(ProjectCode: Code[20]; SourceLangISO: Text[10]; TargetLangISO: Text[10]; FileName: Text; var InS: InStream)
    begin
        ParseAndInsert(ProjectCode, FileName, InS, 'Target', SourceLangISO, TargetLangISO);
    end;

    local procedure ParseAndInsert(ProjectCode: Code[20]; FileName: Text; var InS: InStream; Mode: Text; SourceLangISO: Text[10]; TargetLangISO: Text[10])
    var
        BCXBaseTranslationNotes: Record "BCX Base Translation Notes";
        BCXBaseTranslationTarget: Record "BCX Base Translation Target";
        BCXTranslationNote: Record "BCX Translation Note";
        BCXTranslationProject: Record "BCX Translation Project";
        BCXTranslationSource: Record "BCX Translation Source";
        BCXTranslationTarget: Record "BCX Translation Target";
        ExistingBCXTranslationTarget: Record "BCX Translation Target";
        RecTargetLanguage: Record Language;
        BCXXMLHelper: Codeunit "BCX XML Helper";

        i: Integer;
        j: Integer;
        NoteText: Text;
        ns: Text;
        SourceText: Text;
        TargetText: Text;
        NotePriority: Text[10];
        NoteAnnotates: Text[50];
        SizeUnit: Text[50];
        TargetStatus: Text[50];
        TranslateAttr: Text[50];
        NoteFrom: Text[100];
        AlObjectTarget: Text[250];

        // fields extracted from trans-unit
        TransUnitId: Text[250];

        XmlDoc: XmlDocument;
        FileEl: XmlElement;
        NoteEl: XmlElement;
        RootEl: XmlElement;
        TransEl: XmlElement;
        FileNode: XmlNode;
        NoteNode: XmlNode;
        sn: XmlNode;
        tn: XmlNode;
        TransNode: XmlNode;
        FileElements: XmlNodeList;

        // notes
        NoteList: XmlNodeList;
        SourceNodes: XmlNodeList;
        TargetNodes: XmlNodeList;

        TransUnitList: XmlNodeList;


    begin
        // Parse XML
        BCXXMLHelper.ReadXmlFromInStream(InS, XmlDoc);
        BCXXMLHelper.GetRoot(XmlDoc, RootEl); // <xliff>

        // Namespace handling: many XLIFF have default namespace; use it when selecting children
        ns := RootEl.NamespaceUri();

        // Get the first <file> element under root (we need 'original', source/target languages possibly)
        FileElements := RootEl.GetChildElements('file', ns);
        if FileElements.Count() = 0 then
            FileElements := RootEl.GetChildElements('file'); // fallback
        if FileElements.Count() > 0 then begin
            FileElements.Get(1, FileNode);
            FileEl := FileNode.AsXmlElement();

#pragma warning disable AA0139
            // If Mode didn't pass source/target ISO, take from file attributes
            if SourceLangISO = '' then
                SourceLangISO := BCXXMLHelper.GetAttr(FileEl, 'source-language');

            if TargetLangISO = '' then
                TargetLangISO := BCXXMLHelper.GetAttr(FileEl, 'target-language');
#pragma warning restore AA0139


            RecTargetLanguage.SetRange("BCX ISO code", TargetLangISO);
            RecTargetLanguage.FindFirst();

            // If the <file original="..."> contains an original project name, update project (optional)
            if (Mode = 'Source') then begin
                BCXTranslationProject.Get(ProjectCode);
                BCXTranslationProject."File Name" := CopyStr(FileName, 1, MaxStrLen(BCXTranslationProject."File Name"));
                if BCXXMLHelper.GetAttr(FileEl, 'original') <> '' then
                    BCXTranslationProject.Validate("Project Name", CopyStr(BCXXMLHelper.GetAttr(FileEl, 'original'), 1, MaxStrLen(BCXTranslationProject."Project Name")));

                BCXTranslationProject.Modify(true);
            end;
        end;

        // Find all trans-unit elements anywhere under the document.
        // Use GetDescendantElements so it finds them even if nested.
        TransUnitList := XmlDoc.GetDescendantElements('trans-unit', ns);

        for i := 1 to TransUnitList.Count() do begin
            TransUnitList.Get(i, TransNode);
            TransEl := TransNode.AsXmlElement();

            // Attributes
            TransUnitId := CopyStr(BCXXMLHelper.GetAttr(TransEl, 'id'), 1, MaxStrLen(TransUnitId));
            SizeUnit := CopyStr(BCXXMLHelper.GetAttr(TransEl, 'size-unit'), 1, MaxStrLen(SizeUnit));
            TranslateAttr := CopyStr(BCXXMLHelper.GetAttr(TransEl, 'translate'), 1, MaxStrLen(TranslateAttr));
            AlObjectTarget := CopyStr(BCXXMLHelper.GetAttr(TransEl, 'al-object-target'), 1, MaxStrLen(AlObjectTarget));

            // Child elements: source (optional content)
            SourceText := '';
            SourceNodes := TransEl.GetChildElements('source', ns);
            if (SourceNodes.Count() = 0) then
                SourceNodes := TransEl.GetChildElements('source'); // fallback

            if (SourceNodes.Count() > 0) then begin
                SourceNodes.Get(1, sn);
                SourceText := sn.AsXmlElement().InnerText();
            end;

            // Child elements: target (optional)
            TargetText := '';
            TargetNodes := TransEl.GetChildElements('target', ns);
            if (TargetNodes.Count() = 0) then
                TargetNodes := TransEl.GetChildElements('target'); // fallback
            if (TargetNodes.Count() > 0) then begin
                TargetNodes.Get(1, tn);
                TargetText := tn.AsXmlElement().InnerText();
                TargetStatus := CopyStr(BCXXMLHelper.GetAttr(tn.AsXmlElement(), 'state'), 1, MaxStrLen(TargetStatus));
            end;

            // If both source and target empty -> skip
            if (SourceText = '') and (TargetText = '') then
                continue;

            // Prepare notes collection for this trans-unit
            NoteList := TransEl.GetChildElements('note', ns);
            if NoteList.Count() = 0 then
                NoteList := TransEl.GetChildElements('note');

            // Insert into appropriate table depending on Mode
#pragma warning disable AA0022
            if Mode = 'Source' then begin
                BCXTranslationSource.Init();
                BCXTranslationSource."Project Code" := ProjectCode;
                BCXTranslationSource."Trans-Unit Id" := CopyStr(TransUnitId, 1, MaxStrLen(BCXTranslationSource."Trans-Unit Id"));
                BCXTranslationSource.Source := CopyStr(SourceText, 1, MaxStrLen(BCXTranslationSource.Source));


                // handle notes as BCX Translation Notes
                for j := 1 to NoteList.Count() do begin
                    NoteList.Get(j, NoteNode);
                    NoteEl := NoteNode.AsXmlElement();
                    NoteFrom := CopyStr(BCXXMLHelper.GetAttr(NoteEl, 'from'), 1, MaxStrLen(NoteFrom));
                    NoteAnnotates := CopyStr(BCXXMLHelper.GetAttr(NoteEl, 'annotates'), 1, MaxStrLen(NoteAnnotates));
                    NotePriority := CopyStr(BCXXMLHelper.GetAttr(NoteEl, 'priority'), 1, MaxStrLen(NotePriority));
                    NoteText := CopyStr(NoteEl.InnerText(), 1, MaxStrLen(BCXTranslationNote.Note));

                    BCXTranslationNote.Init();
                    BCXTranslationNote."Project Code" := ProjectCode;
                    BCXTranslationNote."Trans-Unit Id" := BCXTranslationSource."Trans-Unit Id";
                    BCXTranslationNote.From := NoteFrom;
                    BCXTranslationNote.Annotates := NoteAnnotates;
                    BCXTranslationNote.Priority := NotePriority;
                    BCXTranslationNote.Note := CopyStr(NoteText, 1, MaxStrLen(BCXTranslationNote.Note));
                    if ((BCXTranslationNote.Note <> '') and ((BCXTranslationSource."Field Name" = '') or (BCXTranslationNote.From = 'Xliff Generator'))) then
                        BCXTranslationSource."Field Name" := BCXTranslationNote.Note;
                    if not BCXTranslationNote.Insert(false) then
                        BCXTranslationNote.Modify(false);
                end;
                if not BCXTranslationSource.Insert(false) then
                    BCXTranslationSource.Modify(false);
            end else
                if Mode = 'BaseTarget' then begin
                    BCXBaseTranslationTarget.Init();
                    BCXBaseTranslationTarget."Project Code" := ProjectCode;
                    BCXBaseTranslationTarget."Trans-Unit Id" := CopyStr(TransUnitId, 1, MaxStrLen(BCXBaseTranslationTarget."Trans-Unit Id"));
                    BCXBaseTranslationTarget.Source := CopyStr(SourceText, 1, MaxStrLen(BCXBaseTranslationTarget.Source));
                    BCXBaseTranslationTarget.Target := CopyStr(TargetText, 1, MaxStrLen(BCXBaseTranslationTarget.Target));
                    BCXBaseTranslationTarget."size-unit" := CopyStr(SizeUnit, 1, MaxStrLen(BCXBaseTranslationTarget."size-unit"));
                    BCXBaseTranslationTarget.TranslateAttr := CopyStr(TranslateAttr, 1, MaxStrLen(BCXBaseTranslationTarget.TranslateAttr));
                    BCXBaseTranslationTarget."al-object-target" := CopyStr(AlObjectTarget, 1, MaxStrLen(BCXBaseTranslationTarget."al-object-target"));
                    BCXBaseTranslationTarget.Validate("Target Language ISO code", TargetLangISO);
                    BCXBaseTranslationTarget."Target Language" := RecTargetLanguage.Code;

                    // Base target notes => BCX Base Translation Notes
                    for j := 1 to NoteList.Count() do begin
                        NoteList.Get(j, NoteNode);
                        NoteEl := NoteNode.AsXmlElement();
                        NoteFrom := CopyStr(BCXXMLHelper.GetAttr(NoteEl, 'from'), 1, MaxStrLen(NoteFrom));
                        NoteAnnotates := CopyStr(BCXXMLHelper.GetAttr(NoteEl, 'annotates'), 1, MaxStrLen(NoteAnnotates));
                        NotePriority := CopyStr(BCXXMLHelper.GetAttr(NoteEl, 'priority'), 1, MaxStrLen(NotePriority));
                        NoteText := CopyStr(NoteEl.InnerText(), 1, MaxStrLen(BCXBaseTranslationNotes.Note));

                        BCXBaseTranslationNotes.Init();
                        BCXBaseTranslationNotes."Project Code" := ProjectCode;
                        BCXBaseTranslationNotes."Trans-Unit Id" := BCXBaseTranslationTarget."Trans-Unit Id";
                        BCXBaseTranslationNotes.From := NoteFrom;
                        BCXBaseTranslationNotes.Annotates := NoteAnnotates;
                        BCXBaseTranslationNotes.Priority := NotePriority;
                        BCXBaseTranslationNotes.Note := CopyStr(NoteText, 1, MaxStrLen(BCXBaseTranslationNotes.Note));
                        if ((BCXBaseTranslationNotes.Note <> '') and ((BCXBaseTranslationTarget."Field Name" = '') or (BCXBaseTranslationNotes.From = 'Xliff Generator'))) then
                            BCXBaseTranslationTarget."Field Name" := BCXBaseTranslationNotes.Note;
                        if not BCXBaseTranslationNotes.Insert(false) then
                            BCXBaseTranslationNotes.Modify(false);

                        if not BCXBaseTranslationTarget.Insert(false) then
                            BCXBaseTranslationTarget.Modify(false);
                    end;
                end else begin // Mode = 'Target'
                    BCXTranslationTarget.Init();
                    BCXTranslationTarget."Project Code" := ProjectCode;
                    BCXTranslationTarget."Trans-Unit Id" := CopyStr(TransUnitId, 1, MaxStrLen(BCXTranslationTarget."Trans-Unit Id"));
                    BCXTranslationTarget.Source := CopyStr(SourceText, 1, MaxStrLen(BCXTranslationTarget.Source));
                    BCXTranslationTarget.Target := CopyStr(TargetText, 1, MaxStrLen(BCXTranslationTarget.Target));
                    BCXTranslationTarget."Target Language ISO code" := TargetLangISO;

                    BCXTranslationTarget.Translate := false;
                    if (BCXTranslationTarget.Target = '') then begin
                        ExistingBCXTranslationTarget.Init();
                        ExistingBCXTranslationTarget.SetRange(Source, BCXTranslationTarget.Source);
                        ExistingBCXTranslationTarget.SetRange("Target Language ISO code", BCXTranslationTarget."Target Language ISO code");
                        ExistingBCXTranslationTarget.SetRange(Translate, false);
                        if ExistingBCXTranslationTarget.FindFirst() then
                            BCXTranslationTarget.Target := ExistingBCXTranslationTarget.Target
                        else
                            BCXTranslationTarget.Translate := true;
                    end else
                        if (TargetStatus = 'needs-adaptation') or (TargetStatus = 'needs-translation') then
                            BCXTranslationTarget.Translate := true
                        else
                            BCXTranslationTarget.Translate := false;


                    BCXTranslationTarget."size-unit" := CopyStr(SizeUnit, 1, MaxStrLen(BCXTranslationTarget."size-unit"));
                    BCXTranslationTarget.TranslateAttr := CopyStr(TranslateAttr, 1, MaxStrLen(BCXTranslationTarget.TranslateAttr));
                    BCXTranslationTarget."al-object-target" := CopyStr(AlObjectTarget, 1, MaxStrLen(BCXTranslationTarget."al-object-target"));

                    BCXTranslationTarget."Target Language" := RecTargetLanguage.Code;

                    // Translation notes => BCX Translation Notes
                    for j := 1 to NoteList.Count() do begin
                        NoteList.Get(j, NoteNode);
                        NoteEl := NoteNode.AsXmlElement();
                        NoteFrom := CopyStr(BCXXMLHelper.GetAttr(NoteEl, 'from'), 1, MaxStrLen(NoteFrom));
                        NoteAnnotates := CopyStr(BCXXMLHelper.GetAttr(NoteEl, 'annotates'), 1, MaxStrLen(NoteAnnotates));
                        NotePriority := CopyStr(BCXXMLHelper.GetAttr(NoteEl, 'priority'), 1, MaxStrLen(NotePriority));
                        NoteText := CopyStr(NoteEl.InnerText(), 1, MaxStrLen(BCXTranslationNote.Note));

                        BCXTranslationNote.Init();
                        BCXTranslationNote."Project Code" := ProjectCode;
                        BCXTranslationNote."Trans-Unit Id" := BCXTranslationTarget."Trans-Unit Id";
                        BCXTranslationNote.From := NoteFrom;
                        BCXTranslationNote.Annotates := NoteAnnotates;
                        BCXTranslationNote.Priority := NotePriority;
                        BCXTranslationNote.Note := CopyStr(NoteText, 1, MaxStrLen(BCXTranslationNote.Note));
                        if ((BCXTranslationNote.Note <> '') and ((BCXTranslationTarget."Field Name" = '') or (BCXTranslationNote.From = 'Xliff Generator'))) then
                            BCXTranslationTarget."Field Name" := BCXTranslationNote.Note;
                        if not BCXTranslationNote.Insert(false) then
                            BCXTranslationNote.Modify(false);
                    end;

                    if not BCXTranslationTarget.Insert(false) then
                        BCXTranslationTarget.Modify(false);
                end;
#pragma warning restore AA0022
        end;
    end;
}