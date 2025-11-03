
page 78602 "BCX Target Language List"
{
    Caption = 'Target Language List';
    DataCaptionFields = "Project Code", "Project Name";
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "BCX Target Language";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Project Name"; Rec."Project Name")
                {
                    ApplicationArea = All;
                    Caption = 'Project Name';
                    QuickEntry = false;
                    ToolTip = 'Name of the project.';

                }
                field("Source Language"; Rec."Source Language")
                {
                    ApplicationArea = All;
                    Caption = 'Source Language';
                    QuickEntry = false;
                    ToolTip = 'Source language of the project.';

                }
                field("Source Language ISO code"; Rec."Source Language ISO code")
                {
                    ApplicationArea = All;
                    Caption = 'Source Language ISO code';
                    QuickEntry = false;
                    ToolTip = 'ISO code of the source language of the project.';
                }

                field("Target Language"; Rec."Target Language")
                {
                    ApplicationArea = All;
                    Caption = 'Target Language';
                    ToolTip = 'Target language to translate to.';
                }
                field("Target Language ISO code"; Rec."Target Language ISO code")
                {
                    ApplicationArea = All;
                    Caption = 'Target Language ISO code';
                    QuickEntry = false;
                    ToolTip = 'ISO code of the target language.';
                }
                field("Equivalent Language"; Rec."Equivalent Language")
                {
                    ApplicationArea = All;
                    Caption = 'Equivalent Language';
                    QuickEntry = false;
                    ToolTip = 'Equivalent language to use instead of the target language.';
                }
                field("Equivalent Language ISO code"; Rec."Equivalent Language ISO code")
                {
                    ApplicationArea = All;
                    Caption = 'Equivalent Language ISO code';
                    QuickEntry = false;
                    ToolTip = 'ISO code of the equivalent language.';
                }
            }
        }
        area(FactBoxes)
        {
            part(FactBox; "BCX Trans Source Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Project Code" = field("Project Code");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Translation Target")
            {
                ApplicationArea = All;
                Caption = 'Translation Target';
                Image = Translate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Open the translation target.';

                trigger OnAction()
                var
                    TargetRec: Record "BCX Translation Target";
                    TranslationTargetList: Page "BCX Translation Target List";
                    TargetLang: Text[10];
                    TargetLangIso: Text[10];
                begin
                    // Determine equivalent language
                    TargetLangIso := Rec."Equivalent Language ISO code" <> '' ? Rec."Equivalent Language ISO code" : Rec."Target Language ISO code";
                    TargetLang := Rec."Equivalent Language" <> '' ? Rec."Equivalent Language" : Rec."Target Language";

                    TargetRec.SetRange("Project Code", Rec."Project Code");
                    TargetRec.SetRange("Target Language", TargetLang);
                    TargetRec.SetRange("Target Language ISO code", TargetLangIso);

                    TranslationTargetList.SetTableView(TargetRec);
                    TranslationTargetList.Run();

                end;
            }
            action("Translation Terms")
            {
                ApplicationArea = All;
                Caption = 'Translation Terms';
                Image = BeginningText;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Open the translation terms for this project and target language.';

                trigger OnAction()
                var
                    TransTermRec: Record "BCX Translation Term";
                    TranslationTerms: Page "BCX Translation terms";
                    TargetLang: Text[10];
                begin
                    // Determine equivalent language
                    TargetLang := Rec."Equivalent Language ISO code" <> ''
                        ? Rec."Equivalent Language ISO code"
                        : Rec."Target Language ISO code";

                    TransTermRec.SetRange("Project Code", Rec."Project Code");
                    TransTermRec.SetRange("Target Language", TargetLang);

                    TranslationTerms.SetTableView(TransTermRec);
                    TranslationTerms.Run();
                end;
            }
            action("Project Terms")
            {
                ApplicationArea = All;
                Caption = 'Project Terms';
                Image = BeginningText;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "BCX Translation terms";
                RunPageLink = "Project Code" = field("Project Code"),
                            "Target Language" = const('');
                ToolTip = 'Open language neutral translation terms for this project.';
            }
            action("Export Translation Files")
            {
                ApplicationArea = All;
                Caption = 'Export Translation Files';
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Export translation files for the target language or all languages in the project.';

                trigger OnAction()
                var
                    TargetLangRec: Record "BCX Target Language"; // adjust if different
                    TransProject: Record "BCX Translation Project";
                    DataCompression: Codeunit "Data Compression";
                    TempBlob: Codeunit "Temp Blob";
                    ZipBlob: Codeunit "Temp Blob";
                    ExportTranslation: XmlPort "BCX Export Translation Target";
                    InStream: InStream;
                    Choice: Integer;
                    ChoiceTxt: Label 'Export current language only,Export all languages';
                    OutStream: OutStream;
                    FileName: Text;
                    ToFile: Text;
                begin
                    Choice := StrMenu(ChoiceTxt, 1); // default = current language
                    if Choice = 0 then
                        exit; // user cancelled

                    TransProject.Get(Rec."Project Code");

                    if Choice = 1 then begin
                        // -------------------
                        // Export current only
                        // -------------------
                        TempBlob.CreateOutStream(OutStream);
                        ExportTranslation.SetProjectCode(
                            Rec."Project Code",
                            Rec."Source Language ISO code",
                            Rec."Target Language ISO code",
                            Rec."Equivalent Language ISO code");
                        ExportTranslation.SetDestination(OutStream);
                        ExportTranslation.Export();

                        TempBlob.CreateInStream(InStream);
                        FileName := ExportTranslation.GetFilename();
                        ToFile := FileName;
                        if DownloadFromStream(InStream, 'Export Translation', '', 'XLIFF files (*.xlf)|*.xlf', ToFile) then
                            Message('Translation exported to %1', ToFile);
                    end else begin
                        // -------------------
                        // Export all languages to ZIP
                        // -------------------
                        DataCompression.CreateZipArchive();

                        TargetLangRec.SetRange("Project Code", Rec."Project Code");
                        if TargetLangRec.FindSet() then
                            repeat

                                Clear(ExportTranslation); // new instance per language
                                Clear(TempBlob);
                                TempBlob.CreateOutStream(OutStream);
                                ExportTranslation.SetProjectCode(
                                    Rec."Project Code",
                                    Rec."Source Language ISO code",
                                    TargetLangRec."Target Language ISO code",
                                    TargetLangRec."Equivalent Language ISO code");
                                ExportTranslation.SetDestination(OutStream);

                                ExportTranslation.Export();

                                // Use the filename logic from XmlPort itself
                                FileName := ExportTranslation.GetFilename();

                                TempBlob.CreateInStream(InStream);
                                DataCompression.AddEntry(InStream, FileName);
                            until TargetLangRec.Next() = 0;

                        ZipBlob.CreateOutStream(OutStream);
                        DataCompression.SaveZipArchive(OutStream);

                        ZipBlob.CreateInStream(InStream);
                        ToFile := Rec."Project Name" + '_Translations.zip';
                        if DownloadFromStream(InStream, 'Export All Translations', '', 'ZIP files (*.zip)|*.zip', ToFile) then
                            Message('All translations exported to %1', ToFile);
                    end;
                end;
            }


            action("Import Target")
            {
                ApplicationArea = All;
                Caption = 'Import Target';
                Image = ImportLog;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Import translation target from an XLIFF file for the target language.';

                trigger OnAction()
                var
                    TransProject: Record "BCX Translation Project";
                    TransTarget: Record "BCX Translation Target";
                    XliffParser: Codeunit "BCX Xliff Parser";
                    InS: InStream;

                    DeleteWarningTxt: Label 'This will overwrite existing Translation Target entries for %1 - %2', Comment = '%1: Project Code, %2: Target Language ISO code';
                    ImportedTxt: Label 'The file %1 has been imported into project %2', Comment = '%1: File name, %2: Project Code';
                    FileName: Text;
                begin
                    TransTarget.SetRange("Project Code", Rec."Project Code");
                    TransTarget.SetRange("Target Language ISO code", Rec."Target Language ISO code");
                    if not TransTarget.IsEmpty() then begin
                        if not Confirm(DeleteWarningTxt, false, Rec."Project Code", Rec."Target Language ISO code") then
                            exit;
                        TransTarget.DeleteAll(false);
                    end;
                    TransProject.Get(Rec."Project Code");

                    if not File.UploadIntoStream('Select target XLIFF file', '', 'Xliff files (*.xlf;*.xliff)|*.xlf;*.xliff', FileName, InS) then
                        exit;
                    XliffParser.ImportTargetFromStream(Rec."Project Code", Rec."Source Language ISO code", Rec."Target Language ISO code", FileName, InS);
                    Success := true;

                    while (StrPos(FileName, '\') > 0) do
                        FileName := CopyStr(FileName, StrPos(FileName, '\') + 1);
                    if Success then
                        Message(ImportedTxt, FileName, Rec."Project Code");
                end;
            }


        }
    }
    var
        Success: Boolean;

    trigger OnNewRecord(BelowxRec: Boolean)

    begin
        // Set the project code to the filter value the page was called with
        Rec."Project Code" := CopyStr(Format(Rec.GetFilter("Project Code")), 1, MaxStrLen(Rec."Project Code"));
    end;

}
#pragma implicitwith restore
