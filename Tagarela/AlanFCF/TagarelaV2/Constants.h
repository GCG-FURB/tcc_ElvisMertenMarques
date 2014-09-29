//pastas do aplicativo
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define SOUNDS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Sounds"]
#define ICLOUD_FOLDER [[NSFileManager defaultManager]URLForUbiquityContainerIdentifier:nil];
//pastas do aplicativo

//tipos de imagem
#define CATEGORY_TYPE 0
#define SYMBOL_TYPE 1
//tipos de imagem

//geração de PDF
#define LEFT_MARGIN 25
#define RIGHT_MARGIN 25
#define TOP_MARGIN 35
#define BOTTOM_MARGIN 50
#define BOTTOM_FOOTER_MARGIN 32
#define DOC_WIDTH 595
#define DOC_HEIGHT 842
//geração de PDF

#define GOOGLE @"www.google.com"

//#ifdef TAGARELA_TESTE
//    #define TAGARELA_HOST @"http://murmuring-falls-7702.herokuapp.com/" //BASE TESTE
//#else
    #define TAGARELA_HOST @"http://still-scrubland-6051.herokuapp.com/" //BASE PRODUÇÃO
//#endif

//#define TAGARELA_HOST @"http://localhost:3000/"

@interface Constants : NSObject

@end