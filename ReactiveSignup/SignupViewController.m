#import "SignupViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <libextobjc/EXTScope.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface SignupViewController ()

@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) RACSignal *photoSignal;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureImageView];
    [self configurePhotoButton];
    [self configureSubmitButton];
}

- (void)configureImageView {
    RAC(self.imageView, image) = RACObserve(self, photo);
}

- (void)configurePhotoButton {
    @weakify(self);
    RACSignal *photoButtonTextSignal = [RACObserve(self, photo) map:^id(id value) {
        if (value) {
            return @"Change photo";
        }
        else {
            return @"Add photo";
        }
    }];
    [self.photoButton rac_liftSelector:@selector(setTitle:forState:)
                  withSignalsFromArray:@[photoButtonTextSignal,
                                         [RACSignal return:@(UIControlStateNormal)]]];


    [[self.photoButton rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(UIButton *button) {
         @strongify(self);
         UIImagePickerController *imagePicker = [UIImagePickerController new];
         imagePicker.delegate = self;
         [self presentViewController:imagePicker animated:YES completion:nil];
     }];
}

- (void)configureSubmitButton {
    RACSignal *enabledSignal =
        [RACSignal combineLatest:@[RACObserve(self, photo),
                                   self.usernameTextField.rac_textSignal,
                                   self.passwordTextField.rac_textSignal]
                          reduce:^NSNumber *(UIImage *photo, NSString *username, NSString *password){
                              return @(photo && username.length > 0 && password.length > 0);
                          }];

    self.submitButton.rac_command =
    [[RACCommand alloc] initWithEnabled:enabledSignal signalBlock:^RACSignal *(id input) {
        [SVProgressHUD show];

        // IRL, this signal would make a request and send the response as a `next`.
        RACSignal *signUpSignal = [[RACSignal return:@YES] delay:1];

        [signUpSignal subscribeNext:^(id x) {
            [SVProgressHUD dismiss];
            UIAlertController *ac =
                [UIAlertController alertControllerWithTitle:@"success"
                                                    message:@""
                                             preferredStyle:UIAlertControllerStyleAlert];
            [ac addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:ac animated:YES completion:nil];
        }];
        return signUpSignal;
    }];


}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.photo = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end