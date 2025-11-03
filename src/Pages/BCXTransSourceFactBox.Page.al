page 78615 "BCX Trans Source Factbox"
{
    Caption = 'Source Factbox';
    Editable = false;
    PageType = CardPart;
    SourceTable = "BCX Translation Source";

    layout
    {
        area(Content)
        {
            group(Totals)
            {
                Caption = 'Totals';

                field(TotalCaptions; TotalCaptions)
                {
                    ApplicationArea = All;
                    Caption = 'Total Captions';
                    ToolTip = 'Total number of captions in the translation source for the selected project.';
                }
                field(TotalMissingTranslations; TotalMissingTranslations)
                {
                    ApplicationArea = All;
                    Caption = 'Total Missing Translations';
                    ToolTip = 'Total number of missing translations in the translation source for the selected project.';
                }
                field(TotalMissingCaptions; TotalMissingCaptions)
                {
                    ApplicationArea = All;
                    Caption = 'Total Missing Captions';
                    ToolTip = 'Total number of missing captions in the translation source for the selected project.';
                }
            }
        }
    }

    var
        TotalCaptions: Integer;
        TotalMissingCaptions: Integer;
        TotalMissingTranslations: Integer;

    trigger OnAfterGetRecord()
    var
        BCXTranslationSource: Record "BCX Translation Source";
    begin
        BCXTranslationSource.SetRange("Project Code", Rec."Project Code");
        TotalCaptions := BCXTranslationSource.Count();
        BCXTranslationSource.SetRange(Source, '');
        TotalMissingCaptions := BCXTranslationSource.Count();
        BCXTranslationSource.SetFilter(Source, '<>%1', '');
        BCXTranslationSource.SetRange(Source, '');
        TotalMissingTranslations := BCXTranslationSource.Count();
    end;
}
