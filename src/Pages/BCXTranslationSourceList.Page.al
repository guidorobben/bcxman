
page 78601 "BCX Translation Source List"
{
    PageType = List;
    SourceTable = "BCX Translation Source";

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
            }
        }
        area(FactBoxes)
        {
            part(TransNotes; "BCX Translation Notes")
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
            action("Show Empty Captions")
            {
                ApplicationArea = All;
                Caption = 'Show Empty Captions';
                Image = ShowSelected;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Show all captions that are currently empty.';
                trigger OnAction()
                begin
                    Rec.SetRange(Source, '');
                end;
            }
            action("Show All Captions")
            {
                ApplicationArea = All;
                Caption = 'Show All Captions';
                Image = ShowList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Show all captions, including those that are already translated.';
                trigger OnAction()
                begin
                    Rec.SetRange(Source);
                end;
            }
        }
    }
}
#pragma implicitwith restore
