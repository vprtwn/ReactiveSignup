#import "ReactiveSignupViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ReactiveSignupViewController ()

@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) RACSignal *photoSignal;

@end

@implementation ReactiveSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.photoSignal = RACObserve(self, photo);
    [self configureImageView];
    [self configurePhotoButton];
    [self configureTextFields];
    [self configureSubmitButton];
}

- (void)configureImageView {
    RAC(self.imageView, image) = [self.photoSignal map:^UIImage *(UIImage *image) {
        return image;
    }];
}

- (void)configurePhotoButton {
    @weakify(self);
    __weak id weakSelf = self;
    [self.photoSignal subscribeNext:^(UIImage *image) {
        @strongify(self);
        if (image) {
            [self.photoButton setTitle:@"Change photo" forState:UIControlStateNormal];
            return;
        }
        [self.photoButton setTitle:@"Add photo" forState:UIControlStateNormal];
    }];
    [[self.photoButton rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(UIButton *button) {
         @strongify(self);
         UIImagePickerController *imagePicker = [UIImagePickerController new];
         imagePicker.delegate = self;
         [self presentViewController:imagePicker animated:YES completion:nil];
     }];
}

- (void)configureTextFields {
    RAC(self.usernameTextField, textColor) =
    [[self.usernameTextField rac_signalForControlEvents:
      UIControlEventEditingDidBegin | UIControlEventEditingChanged | UIControlEventEditingDidEnd]
     map:^UIColor *(UITextField *sender) {
         return sender.editing ? [UIColor orangeColor] : [UIColor blackColor];
     }];
    RAC(self.passwordTextField, textColor) =
    [[self.passwordTextField rac_signalForControlEvents:
      UIControlEventEditingDidBegin | UIControlEventEditingChanged | UIControlEventEditingDidEnd]
     map:^UIColor *(UITextField *sender) {
         return sender.editing ? [UIColor orangeColor] : [UIColor blackColor];
     }];
}

- (void)configureSubmitButton {
    RAC(self.submitButton, enabled) =
    [RACSignal combineLatest:@[RACObserve(self, photo),
                               self.usernameTextField.rac_textSignal,
                               self.passwordTextField.rac_textSignal]
                      reduce:^NSNumber *(UIImage *photo, NSString *username, NSString *password){
                          return @(photo && username.length > 0 && password.length > 0);
                      }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.photo = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end