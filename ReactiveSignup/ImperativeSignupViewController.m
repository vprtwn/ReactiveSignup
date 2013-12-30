#import "ImperativeSignupViewController.h"

@interface ImperativeSignupViewController ()

@property (strong, nonatomic) UIImage *photo;

@end

@implementation ImperativeSignupViewController

- (void)viewDidLoad {
    [self.photoButton addTarget:self action:@selector(photoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.usernameTextField addTarget:self action:@selector(textFieldDidChange:)
                     forControlEvents:UIControlEventEditingDidBegin | UIControlEventEditingChanged | UIControlEventEditingDidEnd];
    [self.passwordTextField addTarget:self action:@selector(textFieldDidChange:)
                     forControlEvents:UIControlEventEditingDidBegin | UIControlEventEditingChanged | UIControlEventEditingDidEnd];
    [self updateSubmitButton];
}

- (void)setPhoto:(UIImage *)photo {
    _photo = photo;
    self.imageView.image = photo;
    if (photo) {
        [self.photoButton setTitle:@"Change photo" forState:UIControlStateNormal];
    } else {
        [self.photoButton setTitle:@"Add photo" forState:UIControlStateNormal];
    }
    [self updateSubmitButton];
}

- (void)photoButtonAction {
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)textFieldDidChange:(UITextField *)sender {
    [self updateSubmitButton];
    [self updateTextFieldColors];
}

- (void)updateSubmitButton {
    self.submitButton.enabled = self.photo
    && self.usernameTextField.text.length > 0
    && self.passwordTextField.text.length > 0;
}

- (void)updateTextFieldColors {
    self.usernameTextField.textColor = self.usernameTextField.editing ?
    [UIColor orangeColor] : [UIColor blackColor];
    self.passwordTextField.textColor = self.passwordTextField.editing ?
    [UIColor orangeColor] : [UIColor blackColor];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.photo = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

