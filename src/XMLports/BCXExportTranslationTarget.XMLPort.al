xmlport 78601 "BCX Export Translation Target"
{
    Caption = 'Export Translation Target';
    DefaultNamespace = 'urn:oasis:names:tc:xliff:document:1.2';
    Direction = Export;
    Encoding = UTF8;
    Format = Xml;
    PreserveWhiteSpace = true;
    UseDefaultNamespace = true;
    UseRequestPage = false;
    XmlVersionNo = V10;

    schema
    {
        textelement(xliff)
        {
            textattribute(version)
            {
                trigger OnBeforePassVariable()
                begin
                    version := '1.2';
                end;

            }
            textelement(infile)
            {
                XmlName = 'file';
                textattribute(datatype)
                {
                    trigger OnBeforePassVariable()
                    begin
                        datatype := 'xml';
                    end;
                }
                textattribute("source-language")
                {
                    trigger OnBeforePassVariable()
                    begin
                        "source-language" := SourceTransCode;
                    end;
                }
                textattribute("target-language")
                {
                    trigger OnBeforePassVariable()
                    begin
                        "target-language" := TargetTransCode;
                    end;
                }
                textattribute(original)
                {
                    trigger OnBeforePassVariable()
                    begin
                        original := BCXTranslationProject.OrginalAttr;
                    end;
                }
                textelement(body)
                {
                    textelement(group)
                    {
                        textattribute(id1)
                        {
                            XmlName = 'id';
                            trigger OnBeforePassVariable()
                            begin
                                id1 := 'body';
                            end;
                        }
                        tableelement(Target; "BCX Translation Target")
                        {
                            XmlName = 'trans-unit';

                            fieldattribute(id; Target."Trans-Unit Id") { }
                            textattribute("size-unit")
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    "size-unit" := Target."size-unit";
                                end;
                            }
                            textattribute(translate)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    translate := Target.TranslateAttr;
                                end;
                            }
                            textattribute("al-object-target")
                            {
                                Occurrence = Optional;
                                trigger OnAfterAssignVariable()
                                begin
                                    Target."al-object-target" := "al-object-target";
                                end;
                            }
                            fieldelement(Source; Target.Source)
                            {
                                XmlName = 'source';
                            }
                            fieldelement(Target; Target.Target)
                            {
                                XmlName = 'target';
                            }

                            tableelement(note; "BCX Translation Note")
                            {
                                LinkFields = "Project Code" = field("Project Code"), "Trans-Unit Id" = field("Trans-Unit Id");
                                LinkTable = Target;

                                fieldattribute(from; note.From) { }
                                fieldattribute(annotates; note.Annotates) { }
                                fieldattribute(priority; note.Priority) { }
                                fieldattribute(note; Note.Note) { }
                            }

                        }
                    }
                }
            }
        }
    }

    var
        BCXTranslationProject: Record "BCX Translation Project";
        ProjectCode: Code[20];
        EquivalentTransCode: Text[10];
        SourceTransCode: Text[10];
        TargetTransCode: Text[10];

    trigger OnPreXmlPort()
    var
        TargetLanguage: Text;
        TempFile: Text;
    begin
        BCXTranslationProject.Get(Target.GetFilter("Project Code"));
        TargetLanguage := TargetTransCode;
        TempFile := BCXTranslationProject."File Name";

        if StrPos(LowerCase(TempFile), '.g.xlf') > 0 then
            currXMLport.Filename := CopyStr(TempFile, 1, StrPos(LowerCase(TempFile), '.g.xlf')) +
                                     TargetLanguage + '.xlf'
        else
            if StrPos(LowerCase(TempFile), '.xlf') > 0 then
                currXMLport.Filename := CopyStr(TempFile, 1, StrPos(LowerCase(TempFile), '.xlf')) +
                                         TargetLanguage + '.xlf'
            else
                if StrPos(LowerCase(TempFile), '.xlif') > 0 then
                    currXMLport.Filename := CopyStr(TempFile, 1, StrPos(LowerCase(TempFile), '.xlif')) +
                                             TargetLanguage + '.xlif';
    end;

    procedure GetFilename(): Text
    begin
        exit(currXMLport.Filename());
    end;


    procedure SetProjectCode(inProjectCode: Code[20]; InSourceLang: Text[10]; InTargetLang: Text[10])
    begin
        SetProjectCode(inProjectCode, InSourceLang, InTargetLang, '');
    end;

    procedure SetProjectCode(inProjectCode: Code[20]; InSourceLang: Text[10]; InTargetLang: Text[10]; InEquivalentLang: Text[10])
    begin
        Target.Reset();
        Target.SetRange("Project Code", inProjectCode);
        Target.SetRange("Target Language ISO code", (InEquivalentLang <> '') ? InEquivalentLang : InTargetLang);
#pragma warning disable AA0206
        ProjectCode := inProjectCode;
#pragma warning restore AA0206
        SourceTransCode := InSourceLang;
        TargetTransCode := InTargetLang;
        EquivalentTransCode := InEquivalentLang;
    end;

}

