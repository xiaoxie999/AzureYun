//
//  ViewController.m
//  uploadDemo
//
//  Created by apple on 2018/3/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "ViewController.h"

#import <AZSClient/AZSClient.h>

#define AccountFromConnectionString     @"XXXXXX"
#define ContainerReferenceFromName      @"XXXXXX"

@interface ViewController ()

@property (nonatomic, strong) NSDateFormatter * dateFormatter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [_dateFormatter setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
    
    [self uploadBlobToContainer];
}

-(void)createContainer{
    NSError *accountCreationError;
    
    // Create a storage account object from a connection string.
    AZSCloudStorageAccount *account = [AZSCloudStorageAccount accountFromConnectionString:AccountFromConnectionString error:&accountCreationError];
    
    if(accountCreationError){
        NSLog(@"Error in creating account.");
    }
    
    // Create a blob service client object.
    AZSCloudBlobClient *blobClient = [account getBlobClient];
    
    // Create a local container object.
    AZSCloudBlobContainer *blobContainer = [blobClient containerReferenceFromName:ContainerReferenceFromName];
    
    // Create container in your Storage account if the container doesn't already exist
    [blobContainer createContainerIfNotExistsWithCompletionHandler:^(NSError *error, BOOL exists) {
        if (error){
            NSLog(@"Error in creating container.");
        }
    }];
}

-(void)uploadBlobToContainer{
    NSError *accountCreationError;
    
    // Create a storage account object from a connection string.
    AZSCloudStorageAccount *account = [AZSCloudStorageAccount accountFromConnectionString:AccountFromConnectionString error:&accountCreationError];
    
    if(accountCreationError){
        NSLog(@"Error in creating account.");
    }
    
    // Create a blob service client object.
    AZSCloudBlobClient *blobClient = [account getBlobClient];
    
    // Create a local container object.
    AZSCloudBlobContainer *blobContainer = [blobClient containerReferenceFromName:ContainerReferenceFromName];
    
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"123" ofType:@"jpg"];
//    NSString * currentDate = [_dateFormatter stringFromDate:[NSDate date]];
//    NSString * saveName = [NSString stringWithFormat:@"%@.%@",currentDate,[filePath pathExtension]];
    NSString * saveName = [filePath lastPathComponent];
    
    [blobContainer createContainerIfNotExistsWithAccessType:AZSContainerPublicAccessTypeContainer requestOptions:nil operationContext:nil completionHandler:^(NSError *error, BOOL exists)
     {
         if (error){
             NSLog(@"Error in creating container.");
         }
         else{
             // Create a local blob object
             AZSCloudBlockBlob *blockBlob = [blobContainer blockBlobReferenceFromName:saveName];
             
//             // Upload blob to Storage
//             [blockBlob uploadFromText:@"test hello world" completionHandler:^(NSError *error) {
//                 if (error){
//                     NSLog(@"Error in creating blob.");
//                 }
//
//                 [self downloadBlobToString:saveName];
//             }];
             
             [blockBlob uploadFromFileWithPath:filePath completionHandler:^(NSError * _Nullable error) {
                 if (error){
                     NSLog(@"Error in creating blob.");
                 }
                 
                 NSLog(@"%@,%@",[blockBlob.storageUri.primaryUri absoluteString],[blockBlob.storageUri.secondaryUri absoluteString]);
             }];
         }
     }];
}

-(void)downloadBlobToString:(NSString*)name{
    NSError *accountCreationError;
    
    // Create a storage account object from a connection string.
    AZSCloudStorageAccount *account = [AZSCloudStorageAccount accountFromConnectionString:AccountFromConnectionString error:&accountCreationError];
    
    if(accountCreationError){
        NSLog(@"Error in creating account.");
    }
    
    // Create a blob service client object.
    AZSCloudBlobClient *blobClient = [account getBlobClient];
    
    // Create a local container object.
    AZSCloudBlobContainer *blobContainer = [blobClient containerReferenceFromName:ContainerReferenceFromName];
    
    // Create a local blob object
    AZSCloudBlockBlob *blockBlob = [blobContainer blockBlobReferenceFromName:name];
    
    NSString * savePath = [NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),name];
    // Download blob
    [blockBlob downloadToFileWithPath:savePath append:YES completionHandler:^(NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"Error in downloading blob");
        }
        else{
            NSLog(@"%@",savePath);
        }
    }];
}

-(void)listBlobsInContainer{
    NSError *accountCreationError;
    
    // Create a storage account object from a connection string.
    AZSCloudStorageAccount *account = [AZSCloudStorageAccount accountFromConnectionString:AccountFromConnectionString error:&accountCreationError];
    
    if(accountCreationError){
        NSLog(@"Error in creating account.");
    }
    
    // Create a blob service client object.
    AZSCloudBlobClient *blobClient = [account getBlobClient];
    
    // Create a local container object.
    AZSCloudBlobContainer *blobContainer = [blobClient containerReferenceFromName:ContainerReferenceFromName];
    
    //List all blobs in container
    [self listBlobsInContainerHelper:blobContainer continuationToken:nil prefix:nil blobListingDetails:AZSBlobListingDetailsAll maxResults:-1 completionHandler:^(NSError *error) {
        if (error != nil){
            NSLog(@"Error in creating container.");
        }
    }];
}

//List blobs helper method
-(void)listBlobsInContainerHelper:(AZSCloudBlobContainer *)container continuationToken:(AZSContinuationToken *)continuationToken prefix:(NSString *)prefix blobListingDetails:(AZSBlobListingDetails)blobListingDetails maxResults:(NSUInteger)maxResults completionHandler:(void (^)(NSError *))completionHandler
{
    [container listBlobsSegmentedWithContinuationToken:continuationToken prefix:prefix useFlatBlobListing:YES blobListingDetails:blobListingDetails maxResults:maxResults completionHandler:^(NSError *error, AZSBlobResultSegment *results) {
        if (error)
        {
            completionHandler(error);
        }
        else
        {
            for (int i = 0; i < results.blobs.count; i++) {
                AZSCloudBlockBlob * blob = results.blobs[i];
                NSLog(@"%@",[(AZSCloudBlockBlob *)blob blobName]);
            }
            if (results.continuationToken)
            {
                [self listBlobsInContainerHelper:container continuationToken:results.continuationToken prefix:prefix blobListingDetails:blobListingDetails maxResults:maxResults completionHandler:completionHandler];
            }
            else
            {
                completionHandler(nil);
            }
        }
    }];
}

-(void)deleteBlob{
    NSError *accountCreationError;
    
    // Create a storage account object from a connection string.
    AZSCloudStorageAccount *account = [AZSCloudStorageAccount accountFromConnectionString:AccountFromConnectionString error:&accountCreationError];
    
    if(accountCreationError){
        NSLog(@"Error in creating account.");
    }
    
    // Create a blob service client object.
    AZSCloudBlobClient *blobClient = [account getBlobClient];
    
    // Create a local container object.
    AZSCloudBlobContainer *blobContainer = [blobClient containerReferenceFromName:ContainerReferenceFromName];
    
    // Create a local blob object
    AZSCloudBlockBlob *blockBlob = [blobContainer blockBlobReferenceFromName:@"123.jpg"];
    
    // Delete blob
    [blockBlob deleteWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Error in deleting blob.");
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
