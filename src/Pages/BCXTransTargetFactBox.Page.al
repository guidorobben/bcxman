#pragma implicitwith disable
page 78605 "BCX Trans Target Factbox"
{
    Caption = 'Translation Target Factbox';
    Editable = false;
    PageType = CardPart;
    SourceTable = "BCX Translation Target";

    layout
    {
        area(Content)
        {
            group(Line)
            {
                ShowCaption = false;
                field(Instances; Instances)
                {
                    ApplicationArea = All;
                    Caption = 'Instances';
                    ToolTip = 'Number of instances of this target language in the translation source for the selected project.';
                }
            }
            group(Totals)
            {
                field(TotalCaptions; TotalCaptions)
                {
                    ApplicationArea = All;
                    Caption = 'Total Captions';
                    ToolTip = 'Total number of captions in the translation target for the selected project.';
                }
                field(TotalMissingTranslations; TotalMissingTranslations)
                {
                    ApplicationArea = All;
                    Caption = 'Total Missing Translations';
                    ToolTip = 'Total number of missing translations in the translation target for the selected project.';
                }
                field(TotalMissingCaptions; TotalMissingCaptions)
                {
                    ApplicationArea = All;
                    Caption = 'Total Missing Captions';
                    ToolTip = 'Total number of missing captions in the translation target for the selected project.';
                }
            }
        }
    }

    var
        Instances: Integer;
        TotalCaptions: Integer;
        TotalMissingCaptions: Integer;
        TotalMissingTranslations: Integer;

    trigger OnAfterGetCurrRecord()
    var
        BCXTranslationTarget: Record "BCX Translation Target";
    begin
        BCXTranslationTarget.SetRange("Project Code", Rec."Project Code");
        TotalCaptions := BCXTranslationTarget.Count();
        BCXTranslationTarget.SetRange(Source, '');
        TotalMissingCaptions := BCXTranslationTarget.Count();
        BCXTranslationTarget.SetFilter(Source, '<>%1', '');
        BCXTranslationTarget.SetRange(Target, '');
        TotalMissingTranslations := BCXTranslationTarget.Count();
    end;

    trigger OnAfterGetRecord()
    var
        BCXTranslationTarget: Record "BCX Translation Target";
    begin
        BCXTranslationTarget.SetRange(Source, Rec.Source);
        Instances := BCXTranslationTarget.Count();
    end;

}
#pragma implicitwith restore
