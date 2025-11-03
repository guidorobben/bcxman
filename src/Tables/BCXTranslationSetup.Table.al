table 78606 "BCX Translation Setup"
{
    Caption = 'Translation Setup';
    DataClassification = SystemMetadata;

    fields
    {
        field(10; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(30; "Default Source Language code"; Code[10])
        {
            Caption = 'Default Source Language code';
            TableRelation = Language;
        }
        field(40; "Use Free Google Translate"; Boolean)
        {
            Caption = 'Use Free Google Translate';
            InitValue = true;
            // To prepare for other translation API's
        }
        field(50; Logo; MediaSet)
        {
            Caption = 'Logo';
        }

        field(60; "Use OpenAI"; Boolean)
        {
            Caption = 'Use OpenAI';
        }

        field(70; "OpenAI API Key"; Text[512])
        {
            Caption = 'OpenAI API Key';
        }

        field(80; "OpenAI Model"; Option)
        {
            Caption = 'OpenAI Model';
            OptionMembers = "gpt-3.5-turbo","gpt-4o";
        }

        field(90; "Use DeepL"; Boolean)
        {
            Caption = 'Use DeepL';
        }

        field(100; "DeepL API Key"; Text[512])
        {
            Caption = 'DeepL API Key';
        }

    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}