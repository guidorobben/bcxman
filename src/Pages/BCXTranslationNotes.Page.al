#pragma implicitwith disable
page 78604 "BCX Translation Notes"
{
    Caption = 'Translation Notes';
    Editable = false;
    PageType = ListPart;
    SourceTable = "BCX Translation Note";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(From; Rec.From)
                {
                    ApplicationArea = All;
                    Caption = 'From';
                    ToolTip = 'The sender of the note.';

                }
                field(Annotates; Rec.Annotates)
                {
                    ApplicationArea = All;
                    Caption = 'Annotates';
                    ToolTip = 'The person who annotated the note.';

                }
                field(Note; Rec.Note)
                {
                    ApplicationArea = All;
                    Caption = 'Note';
                    ToolTip = 'The content of the note.';
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    Caption = 'Priority';
                    ToolTip = 'The priority of the note.';
                    Visible = false;
                }
            }
        }
    }
}
#pragma implicitwith restore
