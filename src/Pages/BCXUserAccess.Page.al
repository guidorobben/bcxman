page 78612 "BCX User Access"
{
    ApplicationArea = All;
    Caption = 'User Access';
    PageType = List;
    SourceTable = "BCX User Access";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Project Code"; Rec."Project Code")
                {
                    ToolTip = 'Specifies the unique code for the translation project.';

                }
                field("User Id"; Rec."User Id")
                {
                    ToolTip = 'Specifies the unique identifier for the user.';

                }
                field("Project Name"; Rec."Project Name")
                {
                    ToolTip = 'Specifies the name of the translation project.';

                }
                field("User Name"; Rec."User Name")
                {
                    ToolTip = 'Specifies the name of the user.';

                }
            }
        }
    }
    trigger OnOpenPage()
    var
        BCXUserAccess: Record "BCX User Access";
        NoAccessTxt: Label 'No Access';
    begin
        BCXUserAccess.SetRange("User Id", Rec."User Id");
        if not BCXUserAccess.IsEmpty() then
            Error(NoAccessTxt)
    end;
}