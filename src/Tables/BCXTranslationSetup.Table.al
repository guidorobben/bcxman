table 78606 "BCX Translation Setup"
{
    Caption = 'Translation Setup';
    DataClassification = SystemMetadata;

    fields
    {
        field(10; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(30; "Default Source Language code"; Code[10])
        {
            Caption = 'Default Source Language code';
            DataClassification = SystemMetadata;
            TableRelation = Language;
        }
        field(40; "Use Free Google Translate"; Boolean)
        {
            Caption = 'Use Free Google Translate';
            DataClassification = SystemMetadata;
            InitValue = true;
            // To prepare for other translation API's
        }
        field(50; Logo; MediaSet)
        {
            Caption = 'Logo';
            DataClassification = SystemMetadata;
        }

        field(60; "Use OpenAI"; Boolean)
        {
            Caption = 'Use OpenAI';
            DataClassification = SystemMetadata;
        }

        field(70; "OpenAI API Key"; Text[512])
        {
            Caption = 'OpenAI API Key';
            DataClassification = SystemMetadata;
        }

        field(80; "OpenAI Model"; Option)
        {
            Caption = 'OpenAI Model';

            DataClassification = SystemMetadata;
            OptionMembers = "gpt-3.5-turbo","gpt-4o";
        }

        field(90; "Use DeepL"; Boolean)
        {
            Caption = 'Use DeepL';
            DataClassification = SystemMetadata;
        }

        field(100; "DeepL API Key"; Text[512])
        {
            Caption = 'DeepL API Key';
            DataClassification = SystemMetadata;
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