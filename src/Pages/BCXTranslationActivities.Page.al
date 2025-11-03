#pragma implicitwith disable
page 78613 "BCX Translation Activities"
{
    Caption = 'Translation Activities';
    PageType = CardPart;
    SourceTable = "BCX Translation Cue";

    layout
    {
        area(Content)
        {
            cuegroup(Statuses)
            {
                Caption = 'Statuses';
                field("Open Projects"; Rec."Open Projects")
                {
                    ApplicationArea = All;
                    ToolTip = 'Open Projects - not sent to customer.';
                }
                field("Released Projects"; Rec."Released Projects")
                {
                    ApplicationArea = All;
                    ToolTip = 'Released Projects - sent to customer, but not finished.';
                }
                field("Finished Projects"; Rec."Finished Projects")
                {
                    ApplicationArea = All;
                    ToolTip = 'Finished Projects - sent to customer and done for now.';
                }
            }
            cuegroup(Totals)
            {
                Caption = 'Totals';
                field("Projects this Month"; Rec."Projects this Month")
                {
                    ApplicationArea = All;
                    ToolTip = 'Projects this Month - number of projects with activity this month.';
                }
                field("Total Projects"; Rec."Total Projects")
                {
                    ApplicationArea = All;
                    ToolTip = 'Total Projects - total number of projects in the system.';
                }
            }
        }
    }
    var
        ProjectFilterTxt: Text;

    trigger OnOpenPage()
    var
        BCXUserAccess: Record "BCX User Access";
        DateFilterLbl: Label '%1..%2', Comment = '%1: Start date, %2: End date';
        DateFilterTxt: Text;
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(false);
        end;
        DateFilterTxt := StrSubstNo(DateFilterLbl, CalcDate('<-CM>', Today()), Today());
        Rec.SetFilter("Month Date Filter", DateFilterTxt);
        BCXUserAccess.SetRange("User Id", UserId());
        if BCXUserAccess.FindSet() then
            repeat
                if ProjectFilterTxt <> '' then
                    ProjectFilterTxt += '|' + BCXUserAccess."Project Code"
                else
                    ProjectFilterTxt := BCXUserAccess."Project Code";
            until BCXUserAccess.Next() = 0;
        Rec.SetFilter("Project Filter", ProjectFilterTxt);
    end;
}
#pragma implicitwith restore
