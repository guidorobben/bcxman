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
        Target: Record "BCX Translation Target";
    begin
        Target.SetRange("Project Code", Rec."Project Code");
        TotalCaptions := Target.Count();
        Target.SetRange(Source, '');
        TotalMissingCaptions := Target.Count();
        Target.SetFilter(Source, '<>%1', '');
        Target.SetRange(Target, '');
        TotalMissingTranslations := Target.Count();
    end;

    trigger OnAfterGetRecord()
    var
        TransTarget: Record "BCX Translation Target";
    begin
        TransTarget.SetRange(Source, Rec.Source);
        Instances := TransTarget.Count();
    end;

}
#pragma implicitwith restore
