codeunit 78604 "BCX Project Importer"
{
    SingleInstance = false;



    procedure ImportFromZip(ProjectCode: Code[20]; SourceLangIso: Text[10]; Overwrite: Boolean)
    var
        BaseNotes: Record "BCX Base Translation Notes";
        TransBaseTarget: Record "BCX Base Translation Target";
        TransTargetLanguage: Record "BCX Target Language";
        TransNotes: Record "BCX Translation Notes";
        TransProject: Record "BCX Translation Project";
        TransSource: Record "BCX Translation Source";
        TransTarget: Record "BCX Translation Target";
        TransTerm: Record "BCX Translation Term";

        SourceLanguageRec: Record Language;
        TargetLanguageRec: Record Language;
        DataCompression: Codeunit "Data Compression";
        TempBlob: Codeunit "Temp Blob";
        IsSource: Boolean;

        IsXlf: Boolean;
        Dialog: Dialog;
        EntryInS: InStream;
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
            TransSource.SetRange("Project Code", ProjectCode);
            if not TransSource.IsEmpty() then
                TransSource.DeleteAll(false);

            TransTarget.SetRange("Project Code", ProjectCode);
            if not TransTarget.IsEmpty() then
                TransTarget.DeleteAll(false);

            TransTargetLanguage.SetRange("Project Code", ProjectCode);
            if not TransTargetLanguage.IsEmpty() then
                TransTargetLanguage.DeleteAll(false);

            TransBaseTarget.SetRange("Project Code", ProjectCode);
            if not TransBaseTarget.IsEmpty() then
                TransBaseTarget.DeleteAll(false);

            TransNotes.SetRange("Project Code", ProjectCode);
            if not TransNotes.IsEmpty() then
                TransNotes.DeleteAll(false);

            BaseNotes.SetRange("Project Code", ProjectCode);
            if not BaseNotes.IsEmpty() then
                BaseNotes.DeleteAll(false);

            TransTerm.SetRange("Project Code", ProjectCode);
            if not TransTerm.IsEmpty() then
                TransTerm.DeleteAll(false);
        end;

        // Ask user for ZIP
        if not File.UploadIntoStream('Select project ZIP (XLIFF files inside)', '', 'Zip files (*.zip)|*.zip', ProjectFile, InS) then
            exit;

        DataCompression.OpenZipArchive(InS, false);

        Dialog.Open(StepTxt);
        DataCompression.GetEntryList(EntryNames);

        TransProject.SetRange("Project Code", ProjectCode);
        if (not TransProject.FindFirst()) then
            Error('Project %1 not found', ProjectCode);

        // First build list of files to import, source and list of targets
        foreach EntryName in EntryNames do begin
            IsXlf := HasExtension(LowerCase(EntryName), '.xlf') or HasExtension(LowerCase(EntryName), '.xliff');
            if not IsXlf then
                continue;


            DataCompression.ExtractEntry(EntryName, TempBlob);
            // Create a fresh InStream to parse/import
            TempBlob.CreateInStream(EntryInS);

            // Classify the XLF: source vs base target vs normal target
            IsSource := false;
            TargetLangISO := '';
            OriginalProjectName := '';

            // ClassifyXliff expects an InStream and will consume it
            ClassifyXliff(EntryName, EntryInS, IsSource, SourceLangIso, TargetLangISO, OriginalProjectName);

            if IsSource then
                SourceName := EntryName
            else
                TargetsToProcess.Add(EntryName);
        end;

        // If we found a source file, extract and import it first
        if SourceName <> '' then begin

            DataCompression.ExtractEntry(SourceName, TempBlob);

            TempBlob.CreateInStream(EntryInS);

            // Read attributes from the source file (consumes stream)
            ClassifyXliff(SourceName, EntryInS, IsSource, SourceLangIso, TargetLangISO, OriginalProjectName);

            // Update project with original name and source language
            if OriginalProjectName <> '' then
                TransProject.Validate("Project Name", OriginalProjectName);

            SourceLanguageRec.SetRange("BCX ISO code", SourceLangIso);
            if not SourceLanguageRec.FindFirst() then
                Error('Iso code not set for Language %1', SourceLangIso);
            TransProject.Validate("Source Language", SourceLanguageRec.Code);
            TransProject.Modify(true);

            // Recreate stream for actual import (classification consumed it)
            TempBlob.CreateInStream(EntryInS);
            ImportSourceFromStream(ProjectCode, SourceName, EntryInS);
            ImportedCnt += 1;
            Dialog.Update(1, CopyStr(SourceName, 1, 50));
        end;

        // Process remaining target/base-target files
        foreach EntryName in TargetsToProcess do begin
            DataCompression.ExtractEntry(EntryName, TempBlob);
            TempBlob.CreateInStream(EntryInS);

            // Classify to get target-language (consumes stream)
            ClassifyXliff(EntryName, EntryInS, IsSource, SourceLangIso, TargetLangISO, OriginalProjectName);

            // Recreate stream for the import
            TempBlob.CreateInStream(EntryInS);

            TransTargetLanguage.SetRange("Project Code", ProjectCode);
            TransTargetLanguage.SetRange("Target Language ISO code", TargetLangISO);
            if not TransTargetLanguage.FindFirst() then begin
                TransTargetLanguage.Init();
                TransTargetLanguage."Project Code" := ProjectCode;
                TransTargetLanguage."Source Language" := SourceLanguageRec.Code;
                TransTargetLanguage."Source Language ISO code" := SourceLangIso;
                TransTargetLanguage."Target Language ISO code" := TargetLangISO;
                if TargetLangISO <> '' then begin
                    TargetLanguageRec.SetRange("BCX ISO code", TargetLangISO);
                    if TargetLanguageRec.FindFirst() then
                        TransTargetLanguage."Target Language" := TargetLanguageRec.Code;
                end;
                TransTargetLanguage.Insert();
            end;

            // If target-language equals source-language, we treat it as Ba se Target 
            if (TargetLangISO <> '') and (TargetLangISO = SourceLangIso) then begin
                ImportBaseTargetFromStream(ProjectCode, SourceLangIso, TargetLangISO, EntryName, EntryInS);
                ImportTargetFromStream(ProjectCode, SourceLangIso, TargetLangISO, EntryName, EntryInS);      // Also import as normal target to have editable copy
            end else
                ImportTargetFromStream(ProjectCode, SourceLangIso, TargetLangISO, EntryName, EntryInS);

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
        TransProject: Record "BCX Translation Project";
        XliffParser: Codeunit "BCX Xliff Parser";
    begin
        // Use the new code-based parser instead of the XmlPort
        XliffParser.ImportSourceFromStream(ProjectCode, FileName, InS);

        // Update the stored file name on the project 
        if TransProject.Get(ProjectCode) then begin
            TransProject.Validate("File Name", FileName);
            TransProject.Modify(true);
        end;
    end;

    local procedure ImportBaseTargetFromStream(ProjectCode: Code[20]; SrcLang: Text[10]; TgtLang: Text[10]; FileName: Text; var InS: InStream)
    var
        XliffParser: Codeunit "BCX Xliff Parser";
    begin
        XliffParser.ImportBaseTargetFromStream(ProjectCode, SrcLang, TgtLang, FileName, InS);
    end;


    local procedure ImportTargetFromStream(ProjectCode: Code[20]; SrcLang: Text[10]; TgtLang: Text[10]; FileName: Text; var InS: InStream)
    var
        XliffParser: Codeunit "BCX Xliff Parser";
    begin
        XliffParser.ImportTargetFromStream(ProjectCode, SrcLang, TgtLang, FileName, InS);
    end;

}
