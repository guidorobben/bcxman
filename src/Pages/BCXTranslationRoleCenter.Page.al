page 78614 "BCX Translation Role Center"
{
    Caption = 'Translation Role Center';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            part(Activities; "BCX Translation Activities")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Setup)
            {
                ApplicationArea = All;
                Caption = 'Translation Setup';
                RunObject = page "BCX Translation Setup";
                ToolTip = 'Open the translation setup page.';
            }
        }
        // area(Sections)
        // {
        //     group(SectionsGroupName)
        //     {
        //         Caption = '';
        //         action(SectionsAction)
        //         {
        //             ApplicationArea=All;
        //             //RunObject = Page ObjectName;
        //         }
        //     }
        // }
        area(Embedding)
        {
            action("Translation Projects")
            {
                ApplicationArea = All;
                Caption = 'Translation Projects';
                RunObject = page "BCX Trans Project List";
                ToolTip = 'Open the list of translation projects.';
            }
        }
    }
}