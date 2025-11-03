page 78611 "BCX Languages"
{
    ApplicationArea = All;
    Caption = 'Languages (Translate Module)';
    PageType = List;
    SourceTable = Language;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(Code; Rec.Code)
                {
                    Caption = 'Code';
                    ToolTip = 'Code of the language.';
                }
                field(Name; Rec.Name)
                {
                    Caption = 'Name';
                    ToolTip = 'Name of the language.';
                }
                field("Windows Language ID"; Rec."Windows Language ID")
                {
                    Caption = 'Windows Language ID';
                    ToolTip = 'Windows Language ID of the language.';
                }
                field("Windows Language Name"; Rec."Windows Language Name")
                {
                    Caption = 'Windows Language Name';
                    ToolTip = 'Windows Language Name of the language.';
                }
                field("BCX ISO code"; Rec."BCX ISO code")
                {
                    Caption = 'ISO code';
                    ToolTip = 'ISO code of the language.';
                }
            }
        }
    }
}