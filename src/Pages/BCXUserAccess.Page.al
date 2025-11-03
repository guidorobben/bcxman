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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique code for the translation project.';

                }
                field("User Id"; Rec."User Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier for the user.';

                }
                field("Project Name"; Rec."Project Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the translation project.';

                }
                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = All;
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