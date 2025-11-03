codeunit 78604 "BCX Project Importer"
{
    SingleInstance = false;



    procedure ImportFromZip(ProjectCode: Code[20]; SourceLangIso: Text[10]; Overwrite: Boolean)
    var
        BCXBaseTranslationNotes: Record "BCX Base Translation Notes";
        BCXBaseTranslationTarget: Record "BCX Base Translation Target";
        BCXTargetLanguage: Record "BCX Target Language";
        BCXTranslationNotes: Record "BCX Translation Note";
        BCXTranslationProject: Record "BCX Translation Project";
        BCXTranslationSource: Record "BCX Translation Source";
        BCXTranslationTarget: Record "BCX Translation Target";
        BCXTranslationTerm: Record "BCX Translation Term";

        SourceLanguageRec: Record Language;
        TargetLanguageRec: Record Language;
        DataCompression: Codeunit "Data Compression";
        TempBlob: Codeunit "Temp Blob";
        IsSource: Boolean;

        IsXlf: Boolean;
        Dialog: Dialog;
        EntryInStream: InStream;
        InS: InStream;
        ImportedCnt: Integer;
        DeleteWarningTxt: Label 'This will delete all existing source and translations for project %1', Comment = 'Warning text when overwriting existing project, %1 is replaced with project code.';
        StepTxt: Label 'Importing #1######', Comment = 'Dialog step text. #1###### is replaced with the file name being imported.';
        EntryNames: List of [Text];
        TargetsToProcess: List of [Text];
        EntryName: Text;
        ProjectFile: Text;
        SourceName: Text;
        TargetLangISO: Text[10];
        OriginalProjectName: Text[100];
    begin
        // Optional cleanup if overwrite
        if Overwrite then begin
            if (Confirm(DeleteWarningTxt, false, ProjectCode) = false) then
                exit;
            BCXTranslationSource.SetRange("Project Code", ProjectCode);
            if not BCXTranslationSource.IsEmpty() then
                BCXTranslationSource.DeleteAll(false);

            BCXTranslationTarget.SetRange("Project Code", ProjectCode);
            if not BCXTranslationTarget.IsEmpty() then
                BCXTranslationTarget.DeleteAll(false);

            BCXTargetLanguage.SetRange("Project Code", ProjectCode);
            if not BCXTargetLanguage.IsEmpty() then
                BCXTargetLanguage.DeleteAll(false);

            BCXBaseTranslationTarget.SetRange("Project Code", ProjectCode);
            if not BCXBaseTranslationTarget.IsEmpty() then
                BCXBaseTranslationTarget.DeleteAll(false);

            BCXTranslationNotes.SetRange("Project Code", ProjectCode);
            if not BCXTranslationNotes.IsEmpty() then
                BCXTranslationNotes.DeleteAll(false);

            BCXBaseTranslationNotes.SetRange("Project Code", ProjectCode);
            if not BCXBaseTranslationNotes.IsEmpty() then
                BCXBaseTranslationNotes.DeleteAll(false);

            BCXTranslationTerm.SetRange("Project Code", ProjectCode);
            if not BCXTranslationTerm.IsEmpty() then
                BCXTranslationTerm.DeleteAll(false);
        end;

        // Ask user for ZIP
        if not File.UploadIntoStream('Select project ZIP (XLIFF files inside)', '', 'Zip files (*.zip)|*.zip', ProjectFile, InS) then
            exit;

        DataCompression.OpenZipArchive(InS, false);

        Dialog.Open(StepTxt);
        DataCompression.GetEntryList(EntryNames);

        BCXTranslationProject.SetRange("Project Code", ProjectCode);
        if (not BCXTranslationProject.FindFirst()) then
            Error('Project %1 not found', ProjectCode);

        // First build list of files to import, source and list of targets
        foreach EntryName in EntryNames do begin
            IsXlf := HasExtension(LowerCase(EntryName), '.xlf') or HasExtension(LowerCase(EntryName), '.xliff');
            if not IsXlf then
                continue;


            DataCompression.ExtractEntry(EntryName, TempBlob);
            // Create a fresh InStream to parse/import
            TempBlob.CreateInStream(EntryInStream);

            // Classify the XLF: source vs base target vs normal target
            IsSource := false;
            TargetLangISO := '';
            OriginalProjectName := '';

            // ClassifyXliff expects an InStream and will consume it
            ClassifyXliff(EntryName, EntryInStream, IsSource, SourceLangIso, TargetLangISO, OriginalProjectName);

            if IsSource then
                SourceName := EntryName
            else
                TargetsToProcess.Add(EntryName);
        end;

        // If we found a source file, extract and import it first
        if SourceName <> '' then begin

            DataCompression.ExtractEntry(SourceName, TempBlob);

            TempBlob.CreateInStream(EntryInStream);

            // Read attributes from the source file (consumes stream)
            ClassifyXliff(SourceName, EntryInStream, IsSource, SourceLangIso, TargetLangISO, OriginalProjectName);

            // Update project with original name and source language
            if OriginalProjectName <> '' then
                BCXTranslationProject.Validate("Project Name", OriginalProjectName);

            SourceLanguageRec.SetRange("BCX ISO code", SourceLangIso);
            if not SourceLanguageRec.FindFirst() then
                Error('Iso code not set for Language %1', SourceLangIso);
            BCXTranslationProject.Validate("Source Language", SourceLanguageRec.Code);
            BCXTranslationProject.Modify(true);

            // Recreate stream for actual import (classification consumed it)
            TempBlob.CreateInStream(EntryInStream);
            ImportSourceFromStream(ProjectCode, SourceName, EntryInStream);
            ImportedCnt += 1;
            Dialog.Update(1, CopyStr(SourceName, 1, 50));
        end;

        // Process remaining target/base-target files
        foreach EntryName in TargetsToProcess do begin
            DataCompression.ExtractEntry(EntryName, TempBlob);
            TempBlob.CreateInStream(EntryInStream);

            // Classify to get target-language (consumes stream)
            ClassifyXliff(EntryName, EntryInStream, IsSource, SourceLangIso, TargetLangISO, OriginalProjectName);

            // Recreate stream for the import
            TempBlob.CreateInStream(EntryInStream);

            BCXTargetLanguage.SetRange("Project Code", ProjectCode);
            BCXTargetLanguage.SetRange("Target Language ISO code", TargetLangISO);
            if not BCXTargetLanguage.FindFirst() then begin
                BCXTargetLanguage.Init();
                BCXTargetLanguage."Project Code" := ProjectCode;
                BCXTargetLanguage."Source Language" := SourceLanguageRec.Code;
                BCXTargetLanguage."Source Language ISO code" := SourceLangIso;
                BCXTargetLanguage."Target Language ISO code" := TargetLangISO;
                if TargetLangISO <> '' then begin
                    TargetLanguageRec.SetRange("BCX ISO code", TargetLangISO);
                    if TargetLanguageRec.FindFirst() then
                        BCXTargetLanguage."Target Language" := TargetLanguageRec.Code;
                end;
                BCXTargetLanguage.Insert();
            end;

            // If target-language equals source-language, we treat it as Ba se Target 
            if (TargetLangISO <> '') and (TargetLangISO = SourceLangIso) then begin
                ImportBaseTargetFromStream(ProjectCode, SourceLangIso, TargetLangISO, EntryName, EntryInStream);
                ImportTargetFromStream(ProjectCode, SourceLangIso, TargetLangISO, EntryName, EntryInStream);      // Also import as normal target to have editable copy
            end else
                ImportTargetFromStream(ProjectCode, SourceLangIso, TargetLangISO, EntryName, EntryInStream);

            ImportedCnt += 1;
            Dialog.Update(1, CopyStr(EntryName, 1, 50));
        end;

        Dialog.Close();
        DataCompression.CloseZipArchive();

        Message(
            'Project %1 import complete. Files: %2',
            ProjectCode, ImportedCnt);
    end;


    local procedure HasExtension(FileName: Text; ExtWithDotLower: Text): Boolean
    var
        extLen: Integer;
        startPos: Integer;
        nameLower: Text;
    begin
        nameLower := LowerCase(FileName);
        extLen := StrLen(ExtWithDotLower);
        if StrLen(nameLower) < extLen then
            exit(false);
        startPos := StrLen(nameLower) - extLen + 1;
        exit(CopyStr(nameLower, startPos, extLen) = ExtWithDotLower);
    end;

    local procedure ClassifyXliff(FileName: Text; var InS: InStream; var IsSource: Boolean; var SourceLang: Text[10]; var TargetLang: Text[10]; var OriginalProjectName: Text[100])
    var
        LangTxt: Text;
        nameLower: Text;
        ns: Text;
        OriginalTxt: Text;
        XmlDoc: XmlDocument;
        Root: XmlElement;
        FileNode: XmlNode;
        FileChildren: XmlNodeList;
    begin
        IsSource := false;
        SourceLang := '';
        TargetLang := '';

        nameLower := LowerCase(FileName);
        if HasExtension(nameLower, '.g.xlf') or HasExtension(nameLower, '.g.xliff') then
            IsSource := true;

        // Parse and get root
        XmlDocument.ReadFrom(InS, XmlDoc);
        XmlDoc.GetRoot(Root);

        // Find the <file> element in the same namespace
        ns := Root.NamespaceUri();
        FileChildren := Root.GetChildElements('file', ns);
        if FileChildren.Count() = 0 then
            FileChildren := Root.GetChildElements('file'); // fallback if ns binding differs

        if FileChildren.Count() = 0 then
            exit; // no <file>; leave langs blank (or raise an error if you prefer)

        FileChildren.Get(1, FileNode); // first <file>

        OriginalTxt := GetAttr(FileNode.AsXmlElement(), 'original');
        if OriginalTxt <> '' then
            OriginalProjectName := CopyStr(OriginalTxt, 1, MaxStrLen(OriginalProjectName));

        LangTxt := GetAttr(FileNode.AsXmlElement(), 'source-language');
        if LangTxt <> '' then
            SourceLang := CopyStr(LangTxt, 1, MaxStrLen(SourceLang));

        LangTxt := GetAttr(FileNode.AsXmlElement(), 'target-language');
        if LangTxt <> '' then
            TargetLang := CopyStr(LangTxt, 1, MaxStrLen(TargetLang));

    end;


    local procedure GetAttr(Element: XmlElement; Name: Text): Text
    var
        Attr: XmlAttribute;
        Attrs: XmlAttributeCollection;
    begin
        if not Element.HasAttributes() then
            exit('');

        Attrs := Element.Attributes();
        foreach Attr in Attrs do
            if LowerCase(Attr.Name()) = LowerCase(Name) then
                exit(Attr.Value());

        exit('');
    end;


    local procedure ImportSourceFromStream(ProjectCode: Code[20]; FileName: Text; var InS: InStream)
    var
        BCXTranslationProject: Record "BCX Translation Project";
        BCXXliffParser: Codeunit "BCX Xliff Parser";
    begin
        // Use the new code-based parser instead of the XmlPort
        BCXXliffParser.ImportSourceFromStream(ProjectCode, FileName, InS);

        // Update the stored file name on the project 
        if BCXTranslationProject.Get(ProjectCode) then begin
            BCXTranslationProject.Validate("File Name", FileName);
            BCXTranslationProject.Modify(true);
        end;
    end;

    local procedure ImportBaseTargetFromStream(ProjectCode: Code[20]; SrcLang: Text[10]; TgtLang: Text[10]; FileName: Text; var InS: InStream)
    var
        BCXXliffParser: Codeunit "BCX Xliff Parser";
    begin
        BCXXliffParser.ImportBaseTargetFromStream(ProjectCode, SrcLang, TgtLang, FileName, InS);
    end;


    local procedure ImportTargetFromStream(ProjectCode: Code[20]; SrcLang: Text[10]; TgtLang: Text[10]; FileName: Text; var InS: InStream)
    var
        BCXXliffParser: Codeunit "BCX Xliff Parser";
    begin
        BCXXliffParser.ImportTargetFromStream(ProjectCode, SrcLang, TgtLang, FileName, InS);
    end;
}
