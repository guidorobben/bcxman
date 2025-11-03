pageextension 78600 "BCX User List" extends Users
{
    actions
    {
        addfirst(processing)
        {
            action("BCX User Access")
            {
                ApplicationArea = All;
                Caption = 'User Access';
                Image = ServiceAccessories;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "BCX User Access";
                RunPageLink = "User Id" = field("User Name");
                ToolTip = 'Set access for the BCX Translation Management app.';
            }
        }
    }
}