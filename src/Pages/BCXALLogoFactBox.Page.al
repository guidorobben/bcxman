#pragma implicitwith disable
page 78610 "BCX AL Logo FactBox"
{
    Caption = 'AL Translation Tool';
    Editable = false;
    PageType = CardPart;
    SourceTable = "BCX Translation Setup";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                ShowCaption = false;
                field(Logo; Rec.Logo)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
            }
        }
    }
}
#pragma implicitwith restore 
