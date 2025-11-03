#pragma implicitwith disable
page 78606 "BCX Translation terms"
{
    AutoSplitKey = true;
    Caption = 'Translation Terms';
    DataCaptionFields = "Project Code", "Target Language";
    LinksAllowed = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = "BCX Translation Term";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Apply Pre-Translation"; Rec."Apply Pre-Translation")
                {
                    ApplicationArea = All;
                    ToolTip = 'If checked, the term is used pre-translation. Leave translation empty to use the term as is.';
                }
                field(Term; Rec.Term)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the term to hardcode for translation. E.g. ''Journal'' must be translated to ''Worksheet''. Every instance of the term will be replaced with the translation.';
                }
                field(Translation; Rec.Translation)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the translation to be inserted for the term. E.g. ''Journal'' must be translated to ''Worksheet''. Every instance of the term will be replaced with the translation.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Copy From General Terms")
            {
                ApplicationArea = All;
                Caption = 'Copy From General Terms';
                Image = ReminderTerms;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Copy translation terms from the general terms list.';

                trigger OnAction()
                var
                    GenTransTerm: Record "BCX Gen. Translation Term";
                    TransTerm: Record "BCX Translation Term";
                begin
                    GenTransTerm.SetFilter("Target Language", Rec."Target Language");
                    if GenTransTerm.FindSet() then
                        repeat
                            TransTerm.TransferFields(GenTransTerm);
                            TransTerm."Project Code" := CopyStr(Rec.GetFilter("Project Code"), 1, 10);
                            if TransTerm.Insert(false) then;
                        until GenTransTerm.Next() = 0;
                end;
            }
            action("Add to General Terms")
            {
                ApplicationArea = All;
                Caption = 'Add to General Terms';
                Image = AddToHome;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Add the current term to the general terms list.';

                trigger OnAction()
                var
                    GenTransTerm: Record "BCX Gen. Translation Term";
                begin
                    GenTransTerm.TransferFields(Rec);
                    if not GenTransTerm.Insert(false) then
                        GenTransTerm.Modify(false);
                end;
            }
        }
    }
}
#pragma implicitwith restore 
