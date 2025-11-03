#pragma implicitwith disable
page 78603 "BCX Translation Target List"
{
    Caption = 'Translation Target List';
    DataCaptionFields = "Project Code", "Target Language ISO code";
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "BCX Translation Target";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The name of the field to be translated.';

                }
                field("Trans-Unit Id"; Rec."Trans-Unit Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'The unique identifier for the translation unit.';
                    Visible = false;

                }

                field(Source; Rec.Source)
                {
                    ApplicationArea = All;
                    ToolTip = 'The original text that needs to be translated.';
                }
                field("Target Language ISO code"; Rec."Target Language ISO code")
                {
                    ApplicationArea = All;
                    ToolTip = 'The ISO code for the target language.';
                    Visible = ShowTargetLanguageCode;
                }
                field(Translate2; Rec.Translate)
                {
                    ApplicationArea = All;
                    Caption = 'Translate';
                    ToolTip = 'Set the Translate field to no if you don''t want it to be translated';
                }
                field(Target; Rec.Target)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the translated text';
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;

                }
                field(Occurrencies; Rec.Occurrencies)
                {
                    ApplicationArea = All;
                    Caption = 'Occurrences';
                    ToolTip = 'Number of occurrences of this source text in the application.';
                    Visible = true;
                }
            }
        }
        area(FactBoxes)
        {
            part(TransNotes; "BCX Translation Notes")
            {
                ApplicationArea = All;
                Editable = false;
                SubPageLink = "Project Code" = field("Project Code"),
                            "Trans-Unit Id" = field("Trans-Unit Id");
            }
            part(TargetFactbox; "BCX Trans Target Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Project Code" = field("Project Code"),
                            "Trans-Unit Id" = field("Trans-Unit Id");
            }

        }

    }

    actions
    {
        area(Processing)
        {
            action(Translate)
            {
                ApplicationArea = All;
                Caption = 'Translate';
                Enabled = ShowTranslate;
                Image = Translation;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Translate the selected text.';

                trigger OnAction()
                var
                    Project: Record "BCX Translation Project";
                    Translater: Codeunit "BCX Translate Dispatcher";
                begin
                    Project.Get(Rec."Project Code");
                    Rec.Target := Translater.Translate(Project."Project Code", Project."Source Language ISO code",
                                              Rec."Target Language ISO code",
                                              Rec.Source);
                    Rec.Target := ReplaceTermInTranslation(Rec."Target Language ISO code", Rec.Target);
                    Rec.Validate(Target);
                end;
            }
            action("Translate All")
            {
                ApplicationArea = All;
                Caption = 'Translate All';
                Enabled = ShowTranslate;
                Image = Translations;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Translate all texts within the current filter.';

                trigger OnAction()
                var
                    MenuSelectionTxt: Label 'Convert all,Convert only missing';
                begin
                    case StrMenu(MenuSelectionTxt, 1) of
                        1:
                            TranslateAll(false);

                        2:
                            TranslateAll(true);
                    end;
                end;
            }
            action(Copy)
            {
                ApplicationArea = All;
                Caption = 'Copy';
                Enabled = ShowTranslate;
                Image = Copy;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Copy the source text to the target text.';

                trigger OnAction()
                begin
                    Rec.Target := Rec.Source;
                    Rec.Validate(Target);
                end;
            }
            action("Copy All")
            {
                ApplicationArea = All;
                Caption = 'Copy All';
                Enabled = ShowTranslate;
                Image = Translations;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Copy all source texts to the target texts within the current filter.';

                trigger OnAction()
                var
                    MenuSelectionTxt: Label 'Copy all,Copy only missing';
                begin
                    case StrMenu(MenuSelectionTxt, 1) of
                        1:
                            CopyAll(false);

                        2:
                            CopyAll(true);
                    end;
                end;
            }
            action("Select All")
            {
                ApplicationArea = All;
                Caption = 'Select All';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Mark all lines to be translated.';
                trigger OnAction()
                var
                    TransTarget: Record "BCX Translation Target";
                    WarningTxt: Label 'Mark all untranslated lines to be translated?';
                begin
                    CurrPage.SetSelectionFilter(TransTarget);
                    if TransTarget.Count() = 1 then
                        TransTarget.Reset();
                    TransTarget.SetRange(Target, '');
                    if Confirm(WarningTxt) then
                        TransTarget.ModifyAll(Translate, true);
                    CurrPage.Update(false);

                end;
            }
            action("Select Empty Translations")
            {
                ApplicationArea = All;
                Caption = 'Select Empty Translations';
                Image = SelectEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Mark all lines with empty translations to be translated.';
                trigger OnAction()
                begin
                    Rec.SetRange(Target, '');
                end;
            }
            action("Deselect All")
            {
                ApplicationArea = All;
                Caption = 'Deselect All';
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Unmark all lines to be translated.';
                trigger OnAction()
                var
                    TransTarget: Record "BCX Translation Target";
                    WarningTxt: Label 'Remove mark from all lines and disable translation?';
                begin
                    CurrPage.SetSelectionFilter(TransTarget);
                    if TransTarget.Count() = 1 then
                        TransTarget.Reset();
                    if Confirm(WarningTxt) then
                        TransTarget.ModifyAll(Translate, false);
                    CurrPage.Update(false);
                end;
            }
            action("Clear All translations")
            {
                ApplicationArea = All;
                Caption = 'Clear All translations within filter';
                Image = RemoveLine;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Clear all translations within the current filter.';
                trigger OnAction()
                var
                    TransTarget: Record "BCX Translation Target";
                    WarningTxt: Label 'Remove all translations?';
                begin
                    CurrPage.SetSelectionFilter(TransTarget);
                    //if TransTarget.Count = 1 then
                    //    TransTarget.Reset();
                    if Confirm(WarningTxt) then
                        TransTarget.ModifyAll(Target, '');
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
                RunObject = page "BCX Translation terms";
                RunPageLink = "Project Code" = field("Project Code"),
                            "Target Language" = field("Target Language ISO code");
                ToolTip = 'Manage translation terms for the current project and target language.';
            }
            action("Export Translation File")
            {
                ApplicationArea = All;
                Caption = 'Export Translation File';
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Export the translation file for the current project and target language.';
                trigger OnAction()
                var
                    TransProject: Record "BCX Translation Project";
                    ExportTranslation: XmlPort "BCX Export Translation Target";
                    WarningTxt: Label 'Export the Translation file?';

                begin
                    if Confirm(WarningTxt) then begin
                        TransProject.Get(Rec."Project Code");
                        case TransProject."NAV Version" of
                            TransProject."NAV Version"::"Dynamics 365 Business Central":
                                begin
                                    ExportTranslation.SetProjectCode(Rec."Project Code", TransProject."Source Language ISO code", Rec."Target Language ISO code");
                                    ExportTranslation.Run();
                                end;

                        end;
                    end;
                end;

            }
            action("Find Duplicates")
            {
                ApplicationArea = All;
                Caption = 'Find Duplicates';
                Image = Find;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Find duplicate source texts and copy existing translations to empty targets.';

                trigger OnAction()
                var
                    FindDuplicatesTxt: Label 'Find Duplicates?';
                begin
                    if Confirm(FindDuplicatesTxt) then
                        FindDuplicates();
                end;
            }
            action("Update From Source")
            {
                ApplicationArea = All;
                Caption = 'Update From Source';
                Image = UpdateXML;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Update target texts from source texts if the source text has changed. Also removes obsolete targets.';

                trigger OnAction()
                var
                    FindDuplicatesTxt: Label 'Update from Source?';
                begin
                    if Confirm(FindDuplicatesTxt) then
                        UpdateFromSource();
                end;
            }

        }
    }
    var
        ShowTargetLanguageCode: Boolean;
        ShowTranslate: Boolean;
        TargetLanguageFilter: Text[10];
        TargetLanguageIsoFilter: Text[10];


    trigger OnOpenPage()
    var
        BCXTargetLanguage: Record "BCX Target Language";
        BCXTranslationSetup: Record "BCX Translation Setup";
        BCXTranslationSource: Record "BCX Translation Source";
        BCXTranslationTarget: Record "BCX Translation Target";
        ExistingBCXTranslationTarget: Record "BCX Translation Target";
    begin
        BCXTranslationSetup.Get();
        ShowTranslate := BCXTranslationSetup."Use Free Google Translate" or BCXTranslationSetup."Use OpenAI" or BCXTranslationSetup."Use DeepL";
        ShowTargetLanguageCode := true;
        TargetLanguageFilter := CopyStr(Rec.GetFilter("Target Language"), 1, 10);
        TargetLanguageIsoFilter := CopyStr(Rec.GetFilter("Target Language ISO code"), 1, 10);
        if (TargetLanguageFilter <> '') then begin

            BCXTranslationSource.SetFilter("Project Code", Rec.GetFilter("Project Code"));
            if BCXTranslationSource.FindSet() then
                repeat
                    BCXTranslationTarget.Init();
                    BCXTranslationTarget.TransferFields(BCXTranslationSource);
                    BCXTranslationTarget."Target Language" := TargetLanguageFilter;
                    BCXTranslationTarget."Target Language ISO code" := TargetLanguageIsoFilter;

                    ExistingBCXTranslationTarget.SetRange(Source, BCXTranslationTarget.Source);
                    ExistingBCXTranslationTarget.SetRange("Target Language ISO code", TargetLanguageIsoFilter);
                    ExistingBCXTranslationTarget.SetRange(Translate, false);
                    if ExistingBCXTranslationTarget.FindFirst() then begin
                        BCXTranslationTarget.Target := ExistingBCXTranslationTarget.Target;
                        BCXTranslationTarget.Translate := false;
                    end else
                        BCXTranslationTarget.Translate := true;

                    if BCXTranslationTarget.Insert() then;
                until BCXTranslationSource.Next() = 0;
        end
        else begin
            // No Target language, loop through all languages. 
            BCXTargetLanguage.SetFilter("Project Code", Rec.GetFilter("Project Code"));
            if BCXTargetLanguage.FindSet() then
                repeat
                    if (BCXTargetLanguage."Equivalent Language" = '') then begin
                        BCXTranslationSource.Reset();
                        BCXTranslationSource.SetFilter("Project Code", Rec.GetFilter("Project Code"));
                        if BCXTranslationSource.FindSet() then
                            repeat
                                BCXTranslationTarget.TransferFields(BCXTranslationSource);
                                BCXTranslationTarget."Target Language" := BCXTargetLanguage."Target Language";
                                BCXTranslationTarget."Target Language ISO code" := BCXTargetLanguage."Target Language ISO code";
                                if BCXTranslationTarget.Insert() then;
                            until BCXTranslationSource.Next() = 0;
                    end;
                until BCXTargetLanguage.Next() = 0;
        end;
    end;


    local procedure CopyAll(inOnlyEmpty: Boolean)
    var
        BCXTranslationProject: Record "BCX Translation Project";
        BCXTranslationTarget: Record "BCX Translation Target";
        CopyDialog: Dialog;
        Counter: Integer;
        TotalCount: Integer;
        DialogTxt: Label 'Copying #1###### of #2######', Comment = '#1 is the number of copied captions, #2 is the total number of captions to process';
    begin
        BCXTranslationProject.Get(Rec."Project Code");
        if inOnlyEmpty then
            BCXTranslationTarget.SetRange(Target, '');
        // TransTarget.SetRange(Translate, true);
        BCXTranslationTarget.SetRange("Project Code", BCXTranslationProject."Project Code");
        BCXTranslationTarget.SetRange("Target Language ISO code", Rec."Target Language ISO code");

        TotalCount := BCXTranslationTarget.Count();
        CopyDialog.Open(DialogTxt);

        if BCXTranslationTarget.FindSet() then
            repeat
                Counter += 1;
                CopyDialog.Update(1, Counter);
                CopyDialog.Update(2, TotalCount);
                BCXTranslationTarget.Target := BCXTranslationTarget.Source;
                BCXTranslationTarget.Translate := false;
                BCXTranslationTarget.Modify();
                Commit(); //Save progress
            until BCXTranslationTarget.Next() = 0;


        CopyDialog.Close();
    end;

    local procedure TranslateAll(inOnlyEmpty: Boolean)
    var
        BCXTranslationProject: Record "BCX Translation Project";
        BCXTranslationTarget: Record "BCX Translation Target";
        BCXTranslationTarget2: Record "BCX Translation Target";
        BCXTranslateDispatcher: Codeunit "BCX Translate Dispatcher";
        TranslateDialog: Dialog;
        Counter: Integer;
        TotalCount: Integer;
        DialogTxt: Label 'Converting #1###### of #2######', Comment = '#1 is the number of converted captions, #2 is the total number of captions to process';
    begin
        BCXTranslationProject.Get(Rec."Project Code");

        if inOnlyEmpty then
            BCXTranslationTarget.SetRange(Target, '');
        BCXTranslationTarget.SetRange(Translate, true);
        BCXTranslationTarget.SetRange("Project Code", BCXTranslationProject."Project Code");
        if (TargetLanguageIsoFilter <> '') then
            BCXTranslationTarget.SetRange("Target Language ISO code", TargetLanguageIsoFilter);

        TotalCount := BCXTranslationTarget.Count();
        TranslateDialog.Open(DialogTxt);

        BCXTranslationTarget.SetCurrentKey(Source);
        if BCXTranslationTarget.FindSet() then
            repeat
                Counter += 1;
                TranslateDialog.Update(1, Counter);
                TranslateDialog.Update(2, TotalCount);

                BCXTranslationTarget.Target :=
                  BCXTranslateDispatcher.Translate(BCXTranslationProject."Project Code",
                                       BCXTranslationProject."Source Language ISO code",
                                       BCXTranslationTarget."Target Language ISO code",
                                       BCXTranslationTarget.Source);
                BCXTranslationTarget.Target :=
                  ReplaceTermInTranslation(BCXTranslationTarget."Target Language ISO code", BCXTranslationTarget.Target);
                BCXTranslationTarget.Translate := false;
                BCXTranslationTarget.Modify();
                // Escape source for filter
                BCXTranslationTarget2.Reset();
                BCXTranslationTarget2.SetRange("Project Code", BCXTranslationProject."Project Code"); // keep within project
                BCXTranslationTarget2.SetFilter(Source, '%1', BCXTranslationTarget.Source);
                BCXTranslationTarget2.SetFilter("Target Language ISO code", BCXTranslationTarget."Target Language ISO code");
                if inOnlyEmpty then
                    BCXTranslationTarget2.SetRange(Target, '');

                BCXTranslationTarget2.ModifyAll(Translate, false);
                BCXTranslationTarget2.ModifyAll(Target, BCXTranslationTarget.Target);

                Commit();
                SelectLatestVersion();

            // Skip already-handled source
            // TransTarget.SetFilter(Source, '<>%1', TransTarget.Source);
            until BCXTranslationTarget.Next() = 0;

        TranslateDialog.Close();
    end;


    // This does the post-translation replacement of terms
    local procedure ReplaceTermInTranslation(TargetLanguageIsoCode: Text[10]; inTarget: Text[2048]) outTarget: Text[2048]
    var
        BCXTranslationTerm: Record "BCX Translation Term";
        Found: Boolean;
        StartLetterIsUppercase: Boolean;
        StartPos: Integer;
    begin
        BCXTranslationTerm.SetRange("Project Code", Rec."Project Code");
        BCXTranslationTerm.SetRange("Target Language", TargetLanguageIsoCode);
        if BCXTranslationTerm.FindSet() then
            repeat
                if BCXTranslationTerm."Apply Pre-Translation" then
                    continue; // Skip terms that are marked for pre-translation only
                StartPos := StrPos(LowerCase(inTarget), LowerCase(BCXTranslationTerm.Term));
                if StartPos > 0 then begin
                    StartLetterIsUppercase := CopyStr(inTarget, StartPos, 1) = UpperCase(CopyStr(inTarget, StartPos, 1));
                    if StartLetterIsUppercase then
                        BCXTranslationTerm.Translation := UpperCase(BCXTranslationTerm.Translation[1]) + CopyStr(BCXTranslationTerm.Translation, 2)
                    else
                        BCXTranslationTerm.Translation := LowerCase(BCXTranslationTerm.Translation[1]) + CopyStr(BCXTranslationTerm.Translation, 2);
                    if (StartPos > 1) then begin
                        outTarget := CopyStr(inTarget, 1, StartPos - 1) +
                                     BCXTranslationTerm.Translation +
                                     CopyStr(inTarget, StartPos + StrLen(BCXTranslationTerm.Term));
                        Found := true;
                    end else begin
                        outTarget := BCXTranslationTerm.Translation +
                                     CopyStr(inTarget, StrLen(BCXTranslationTerm.Term) + 1);
                        Found := true;
                    end;
                end;
                if Found then
                    inTarget := outTarget;
            until BCXTranslationTerm.Next() = 0;
        if not Found then
            outTarget := inTarget;
    end;

    local procedure FindDuplicates()
    var
        BCXTranslationTarget: Record "BCX Translation Target";
        DuplicateBCXTranslationTarget: Record "BCX Translation Target";
        TransBCXTranslationTarget: Record "BCX Translation Target";
        Counter: Integer;
        FinishedTxt: Label '%1 Duplicate captions found', Comment = '%1 is the number of duplicate captions found and updated';
    begin
        BCXTranslationTarget.CopyFilters(Rec);
        BCXTranslationTarget.SetRange(Target, '');
        if BCXTranslationTarget.FindSet() then
            repeat
                TransBCXTranslationTarget.CopyFilters(Rec);
                TransBCXTranslationTarget.SetRange(Source, BCXTranslationTarget.Source);
                TransBCXTranslationTarget.SetFilter(Target, '<>%1', '');
                if TransBCXTranslationTarget.FindFirst() then begin
                    DuplicateBCXTranslationTarget.CopyFilters(Rec);
                    DuplicateBCXTranslationTarget.SetRange(Source, BCXTranslationTarget.Source);
                    DuplicateBCXTranslationTarget.SetRange(Target, '');
                    DuplicateBCXTranslationTarget.ModifyAll(Target, TransBCXTranslationTarget.Target);
                    Counter += 1;
                end;
            until BCXTranslationTarget.Next() = 0;
        Message(FinishedTxt, Counter);
    end;

    local procedure UpdateFromSource()
    var
        BCXTranslationSource: Record "BCX Translation Source";
        BCXTranslationTarget: Record "BCX Translation Target";
        Counter: Integer;
        DeletedCounter: Integer;
        FinishedTxt: Label '%1 source captions updated. %2 obsolete targets deleted.', Comment = '%1 is the number of updated captions, %2 is the number of deleted obsolete targets';
    begin
        BCXTranslationTarget.ModifyAll(Translate, false);
        BCXTranslationSource.SetFilter("Project Code", Rec.GetFilter("Project Code"));
        if BCXTranslationSource.FindSet() then
            repeat
                BCXTranslationTarget.SetRange("Project Code", BCXTranslationSource."Project Code");
                BCXTranslationTarget.SetRange("Trans-Unit Id", BCXTranslationSource."Trans-Unit Id");
                if BCXTranslationTarget.FindSet() then
                    repeat
                        if BCXTranslationTarget.Source <> BCXTranslationSource.Source then begin
                            BCXTranslationTarget.Source := BCXTranslationSource.Source;
                            BCXTranslationTarget.Translate := true;
                            BCXTranslationTarget.Modify();
                            Counter += 1;
                        end;
                    until BCXTranslationTarget.Next() = 0;
            until BCXTranslationSource.Next() = 0;


        // Check for targets that no longer exist in source
        BCXTranslationTarget.Reset();
        BCXTranslationTarget.SetRange("Project Code", Rec.GetFilter("Project Code"));
        if BCXTranslationTarget.FindSet() then
            repeat
                BCXTranslationSource.SetRange("Project Code", BCXTranslationTarget."Project Code");
                BCXTranslationSource.SetRange("Trans-Unit Id", BCXTranslationTarget."Trans-Unit Id");
                if not BCXTranslationSource.FindFirst() then begin
                    BCXTranslationTarget.Delete();
                    DeletedCounter += 1;
                end;
            until BCXTranslationTarget.Next() = 0;
        Message(FinishedTxt, Counter, DeletedCounter);

    end;


}
#pragma implicitwith restore
