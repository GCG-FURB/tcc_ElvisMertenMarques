#import "TGSyncUserContentController.h"

@implementation TGSyncUserContentController

- (id)init
{
    self = [super init];
    if (self) {
        initialSync = false;
        [self setManagedObjectContext:[(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext]];
        
        categoryController = [[TGCategoryController alloc]init];
        symbolController = [[TGSymbolController alloc]init];
        planController = [[TGPlanController alloc]init];
        symbolPlanController = [[TGSymbolPlanController alloc]init];
        symbolHistoricController = [[TGSymbolHistoricController alloc]init];
        userHistoricController = [[TGUserHistoricController alloc]init];
        userController = [[TGUserController alloc]init];
        tutorPatientsController = [[TGTutorPatientsController alloc]init];
        groupPlanController = [[TGGroupPlanController alloc]init];
        
        if (![[TGCurrentUserManager sharedCurrentUserManager]lastSync]) {
            [[TGCurrentUserManager sharedCurrentUserManager]setLastSync:[NSDate date]];
            initialSync = true;
        }
    }
    return self;    
}

- (void)syncAllData
{
    NSDate *lastSync = [NSDate date];
    
    int minuteDifference = [lastSync timeIntervalSinceDate:[[TGCurrentUserManager sharedCurrentUserManager]lastSync]] / 60.0;
    
    if (minuteDifference >= 5 || initialSync) {
        switch ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type]) {
            case 0:
                [self syncPatientRelationshipsFromBackend];
                break;
            case 1:
                [self syncTutorRelationshipsFromBackend];
                break;
            case 2:
                [self syncSpecialistRelationshipsFromBackend];
                break;
        }
        [[TGCurrentUserManager sharedCurrentUserManager]setLastSync:lastSync];
    }else
        [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
}

- (void)syncTutorRelationshipsFromBackend
{
    NSLog(@"Sincronização dos relacionamento do tutor iniciada");    
    
    [tutorPatientsController loadTutorRelationshipsFromBackendWithSuccessHandler:^{
        [self syncCategories];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
    } failHandler:^(NSString *error){
        NSLog(@"Erro ao sincronizar os relacionamentos do tutor %@", error);
    }];
}

- (void)syncSpecialistRelationshipsFromBackend
{
    NSLog(@"Sincronização dos relacionamentos do especialista iniciada");        
    
    [tutorPatientsController loadSpecialistRelationshipsFromBackendWithSuccessHandler:^{
        if ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type] == 0) {
            [self syncCategories];
        } else {
            [self syncPatientRelationshipsForSpecialist];
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
    } failHandler:^(NSString *error) {
        NSLog(@"Erro ao sincronizar os relacionamentos do especialista %@", error);
    }];
}

- (void)syncPatientRelationshipsForSpecialist
{
    NSLog(@"Sincronização dos relacionamentsos do especialista e de seus pacientes iniciada");
    
    [tutorPatientsController loadPatientRelationshipsForSpecialistWithSuccessHandler:^{
        [self syncCategories];
    } failHandler:^(NSString *error){
        NSLog(@"Erro ao sincronizar os relacionamentsos do especialista e de seus pacientes %@", error);
    }];
}

- (void)syncPatientRelationshipsFromBackend
{
    NSLog(@"Sincronização dos relacionamento do paciente iniciada");
    
    [tutorPatientsController loadPatientRelationshipsFromBackendWithPatientID:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID] successHandler:^{
        [self syncSpecialistRelationshipsFromBackend];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
    } failHandler:^(NSString *error) {
        NSLog(@"Erro ao sincronizar os relacionamentos do paciente %@", error);
    }];
}

- (void)syncCategories
{
    NSLog(@"Sincronização de categorias iniciada");
        
    [categoryController loadCategoriesFromBackendWithSuccessHandler:^{
        switch ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type]) {
            case 0:
                [self syncPatientSymbolsFromBackend];
                break;
            case 1:
                [self syncPatientSymbolsFromBackend];
                break;
            case 2:
                [self syncPatientSymbolsFromBackend];
                break;
        }
    } failHandler:^(NSString *error) {
        NSLog(@"Erro ao sincronizar as categorias %@", error);
    }];
}

- (void)syncSymbols
{
    NSLog(@"Sincronização de símbolos iniciada");
    
    [symbolController loadSymbolsFromBackendWithSuccessHandler:^{
        [self syncGroupPlans];
    } failHandler:^(NSString *error){
        NSLog(@"Erro ao sincronizar os símbolos %@", error);
    }];    
}

- (void)syncPatientSymbolsFromBackend
{
    NSLog(@"Sincronização de símbolos do paciente iniciada");
    
    [symbolController loadPatientSymbolsFromBackendWithSuccessHandler:^{
        [self syncSymbols];
    } failHandler:^(NSString *error){
        NSLog(@"Erro ao sincronizar os símbolos do paciente %@", error);
    }];
}

- (void)syncPlans
{
    NSLog(@"Sincronização de planos iniciada");        
    
    [planController loadPlansFromBackendWithSuccessHandler:^{
        [self syncSymbolPlans];
    } failHandler:^(NSString *error) {
        NSLog(@"Erro ao sincronizar os planos %@", error);
    }];
}

- (void)syncGroupPlans
{
    NSLog(@"Sincronização de grupo de planos iniciada");
    
    [groupPlanController loadGroupPlansFromBackendWithSuccessHandler:^{
        [self syncGroupPlanRelationships];
    } failHandler:^(NSString *error) {
        NSLog(@"Erro ao sincronizar os grupos %@", error);
    }];
}

- (void)syncGroupPlanRelationships
{
    NSLog(@"Sincronização de relacionamento entre grupo plano e plano iniciada");
    
    [groupPlanController loadGroupPlanRelationshipsFromBackendWithSuccessHandler:^{
        [self syncPlans];
    } failHandler:^(NSString *error) {
        NSLog(@"Erro ao sincronizar os relacionamentos entre grupo plano e plano %@", error);
    }];
}

- (void)syncSymbolPlans
{
    NSLog(@"Sincronização de símbolos dos planos iniciada");
    
    [symbolPlanController loadSymbolsPlansFromBackendWithSuccessHandler:^{
        [self syncSymbolHistoricsFromBackend];
    } failHandler:^(NSString *error){
        NSLog(@"Erro ao sincronizar os símbolos dos planos %@", error);
    }];
}

- (void)syncSymbolHistoricsFromBackend
{
    NSLog(@"Sincronização de histórico de uso símbolos iniciada");
        
    [symbolHistoricController loadSymbolHistoricsFromBackendWithSuccessHandler:^{
        [self syncObservationsFromBackend];
    } failHandler:^(NSString *error){
        NSLog(@"Erro ao sincronizar o histórico de uso dos símbolos %@", error);
    }];
}

- (void)syncObservationsFromBackend
{
    NSLog(@"Sincronização de histórico do usuário iniciado");
    
    [userHistoricController loadObservationsFromBackendWithSuccessHandler:^{
        NSLog(@"Sincronização completa");
        [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
    } failHandler:^(NSString *error) {
        NSLog(@"Erro ao sincronizar o histórico do usuário %@", error);
    }];        
}

- (void)syncUnsyncedSymbolsToBackend
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Symbol" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == %d", -1];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSArray *unsyncedSymbols = [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];
    
    for (Symbol *unsyncedSymbol in unsyncedSymbols) {
        [symbolController setUnsycedSymbol:unsyncedSymbol];
        [symbolController createSymbolInBackendWithName:[unsyncedSymbol name] andPicture:[UIImage imageWithData:[unsyncedSymbol picture]] andVideoLink:[unsyncedSymbol videoLink] andSound:[unsyncedSymbol sound] andCategory:[unsyncedSymbol category] isUnsyncedSymbol:YES successHandler:^{
            NSLog(@"sucesso");
        } failHandler:^(NSString *error){
            NSLog(@"falha");
        }];
    }        
}

- (void)syncUnsyncedSymbolHistoricsToBackend
{    
    [symbolHistoricController createSymbolHistoricsInBackendWithSuccessHandler:^{
        NSLog(@"sucesso");
    } failHandler:^(NSString *error){
        NSLog(@"%@", error);
    }];
}

- (void)syncUnsyncedObservationsToBackend
{
    [userHistoricController createObservationsInBackendWithSuccessHandler:^{
        NSLog(@"sucesso");
    } failHandler:^(NSString *error){
        NSLog(@"%@", error);
    }];
}

- (void)syncUnsyncedPlansToBackend
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Plan" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == %d", -1];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSArray *unsyncedPlans = [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];
    
    for (Plan *unsyncedPlan in unsyncedPlans) {        
        [planController setUnsycedPlan:unsyncedPlan];
        [planController createPlanInBackendWithName:[unsyncedPlan name] andLayout:[unsyncedPlan layout] andSymbols:nil andGroupPlan:[unsyncedPlan groupPlan] isUnsyncedPlan:YES successHandler:^{
            for (SymbolPlan *unsycedSymbolPlan in [unsyncedPlan symbolPlan]) {
                [symbolPlanController setUnsycedSymbolPlan:unsycedSymbolPlan];
                [symbolPlanController createSymbolPlanInBackendWithSymbol:[[[unsycedSymbolPlan symbol]allObjects]objectAtIndex:0] andPlan:unsyncedPlan andPosition:[unsycedSymbolPlan position] isUnsycedSymbolPlan:YES successHandler:^ {
                    NSLog(@"sucesso ao criar simbolo plano offline");
                } failHandler:^(NSString *error){
                    NSLog(@"Erro ao criar simoblo plano offline %@", error);
                }];
            }
        } failHandler:^(NSString *error) {
            NSLog(@"Erro ao criar plano offline %@", error);
        }];
    }
}

@end