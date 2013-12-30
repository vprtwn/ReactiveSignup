#import "ReactiveSignupViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <libextobjc/EXTScope.h>

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
    // Instead of using a custom setter with a side effect, we can use the signal
    // from our photo property to keep the imageView's image up to date.
    RAC(self.imageView, image) = [self.photoSignal map:^UIImage *(UIImage *image) {
        return image;
    }];
}

- (void)configurePhotoButton {
    // For more on why we're using @weakify and @strongify, see:
    // https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/Documentation/MemoryManagement.md#signals-derived-from-self
    @weakify(self);
    [self.photoSignal subscribeNext:^(UIImage *image) {
        @strongify(self);
        if (image) {
            [self.photoButton setTitle:@"Change photo" forState:UIControlStateNormal];
            return;
        }
        [self.photoButton setTitle:@"Add photo" forState:UIControlStateNormal];
    }];
    // Instead of using the target-action pattern, we can simply subscribe to every UIControlEventTouchUpInside.
    [[self.photoButton rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(UIButton *button) {
         @strongify(self);
         UIImagePickerController *imagePicker = [UIImagePickerController new];
         imagePicker.delegate = self;
         [self presentViewController:imagePicker animated:YES completion:nil];
     }];
}

- (void)configureTextFields {
    // Again, instead of using the target-action pattern, we can subscribe to UIControlEvents.
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
    // We can compose multiple signals with combineLatest:reduce:
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