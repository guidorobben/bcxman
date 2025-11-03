page 78609 "BCX About AL Translation Tool"
{
    Caption = 'About AL Translation Tool';
    PageType = CardPart;
    ShowFilter = false;
    SourceTable = "BCX Translation Setup";

    layout
    {
        area(Content)
        {
            group("About AL Translation Tool")
            {

                Caption = 'About AL Translation Tool';
                InstructionalText = 'Open-Source AL Translate Tool. Source code can be located at https://github.com/Theil-IT/bcxman.';
            }
            grid(App)
            {
                GridLayout = Columns;
                ShowCaption = false;
                group(Group2)
                {
                    ShowCaption = false;
                    field(Version; AppVersion)
                    {
                        ApplicationArea = All;
                        Caption = 'Version';
                        Editable = false;
                        ToolTip = 'Version of the AL Translation Tool app.';
                    }
                    field(AppName; AppName)
                    {
                        ApplicationArea = All;
                        Caption = 'Application Name';
                        Editable = false;
                        ToolTip = 'Name of the AL Translation Tool app.';
                    }
                    field(AppPublisher; AppPublisher)
                    {
                        ApplicationArea = All;
                        Caption = 'Publisher';
                        Editable = false;
                        ToolTip = 'Publisher of the AL Translation Tool app.';
                    }
                }
            }
        }
    }

    var
        AppModuleInfo: ModuleInfo;
        AppName: Text;
        AppPublisher: Text;
        AppVersion: Text[10];

    trigger OnOpenPage()
    begin
        if NavApp.GetCurrentModuleInfo(AppModuleInfo) then begin
            AppVersion := Format(AppModuleInfo.AppVersion());
            AppName := AppModuleInfo.Name();
            AppPublisher := AppModuleInfo.Publisher();
        end;
    end;
}