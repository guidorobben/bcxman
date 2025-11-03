codeunit 78601 "BCX Install Translations"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        User: Record User;
        UserPersonalization: Record "User Personalization";
    begin
        if User.FindSet() then
            repeat
                UserPersonalization.SetRange("User ID", User."User Name");
                if not UserPersonalization.IsEmpty() then
                    if UserPersonalization.FindSet() then
                        repeat
                            UserPersonalization.Validate("Profile ID", 'BCX Translation');
                            UserPersonalization.Modify(false);
                        until UserPersonalization.Next() = 0;
            until User.Next() = 0;
    end;
}