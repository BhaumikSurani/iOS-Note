@interface GetImageFromGalleryViewController ()

@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) NSMutableArray *addressArr;

@end

@implementation GetImageFromGalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Fetch all assets, sorted by date created.
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    options.fetchLimit = 5;
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
    self.assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    self.imageManager = [[PHCachingImageManager alloc] init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.assetsFetchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@“MyTableViewCell” forIndexPath:indexPath];
    
    PHAsset *asset = self.assetsFetchResults[indexPath.row];
    cell.lblFileName.text = [asset valueForKey:@"filename"];
    cell.lblTimeDuration.text = [CommonUtils timeAgoStringFromDate:asset.creationDate];
    
    //Fetch only one time location then store locally
    if(self.addressArr.count-1 == indexPath.row) {
        cell.lblAddress.text = [self.addressArr objectAtIndex:indexPath.row];
    } else {
        cell.lblAddress.text = @"";
        [self.geocoder reverseGeocodeLocation:asset.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            CLPlacemark *placemark = [placemarks lastObject];
            NSString *address = @"";
            if(!(placemark==nil)) {
                if(!([placemark.locality isEqualToString:@""] || [placemark.locality isEqualToString:@"(null)"])) {
                    address = placemark.locality;
                }
                if(!([placemark.ISOcountryCode isEqualToString:@""] || [placemark.ISOcountryCode isEqualToString:@"(null)"])) {
                    if([address isEqualToString:@""]) {
                        address = placemark.locality;
                    } else {
                        address = [NSString stringWithFormat:@"%@, %@", address, placemark.ISOcountryCode];
                    }
                }
            }
            [self.addressArr addObject:address];
            cell.lblAddress.text = address;
        }];
    }

//	  It Getting TargetSize image    
    [self.imageManager requestImageForAsset:asset targetSize:cell.myImage.frame.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
        cell.myImage.image = result;
    }];

//	  It Getting FullSize image    
//    [self.imageManager requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//        cell.myImage.image = [UIImage imageWithData:imageData];
//    }];
    return cell;
}

@end
