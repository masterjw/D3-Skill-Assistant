//
//  MainWindowController.m
//  d3key
//
//  Created by sunghyuk-imac on 2016. 3. 2..
//  Copyright © 2016년 sunghyuk. All rights reserved.
//

#import "MainWindowController.h"
#import <Carbon/Carbon.h>
#import "D3KeyConfigService.h"
#import "KeyEventCaptureService.h"
#include "const.h"


@interface MainWindowController ()

- (void) loadConfig:(NSString *) configId;
- (void) setFieldValues:(D3KeyConfig *) config;
- (D3KeyConfig *) getFieldValues;
- (void) save;

@end

@implementation MainWindowController
{
    NSArray *_keyFieldNames;
    NSArray *_delayFieldNames;
}

- (void) awakeFromNib {
    
    // config id
    configIdSegment.selectedSegment = 0;
    activeSegment.selectedSegment = 0;
    
    _keyFieldNames = @[@"startKeyField",
                       @"stopKeyField1", @"stopKeyField2", @"stopKeyField3", @"stopKeyField4", @"stopKeyField5",
                       @"skillKeyField1", @"skillKeyField2", @"skillKeyField3", @"skillKeyField4", @"skillKeyField5", @"skillKeyField6"
                       ];
    _delayFieldNames = @[@"skillDelayField1", @"skillDelayField2", @"skillDelayField3", @"skillDelayField4", @"skillDelayField5", @"skillDelayField6", @"mouseLeftDelayField", @"mouseRightDelayField"];
    
    for (NSString *name in _keyFieldNames) {
        NSTextField *field = [self valueForKey:name];
        field.delegate = self;
    }
    for (NSString *name in _delayFieldNames) {
        NSTextField *field = [self valueForKey:name];
        field.delegate = self;
    }
    NSTextField *field = [self valueForKey:@"memoField"];
    field.delegate = self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self loadConfig:@"1"];
    
    // check accessiblity
    if (!AXIsProcessTrusted()) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"사용할 수 없음" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"손쉬운 사용 허용 후 다시 실행해주세요"];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            [NSApp terminate:nil];
        }];
    }
}

- (void) loadConfig:(NSString *) configId {
    D3KeyConfig *config = [[D3KeyConfigService sharedService] loadConfig:configId];
    [self setFieldValues:config];
}

- (void) setFieldValues:(D3KeyConfig *) config {
    if (config.startKey != 0xFF) {
        startKeyField.stringValue = [[D3KeyConfigService sharedService] stringWithKeycode:config.startKey];
    }
    for (int i = 1; i < 6; i++) {
        NSTextField *field = [self valueForKey:[NSString stringWithFormat:@"stopKeyField%d", i]];
        CGKeyCode keyCode = [[config valueForKey:[NSString stringWithFormat:@"stopKey%d", i]] unsignedShortValue];
        if (keyCode != 0xFF) {
            field.stringValue = [[D3KeyConfigService sharedService] stringWithKeycode:keyCode];
        } else {
            field.stringValue = @"";
        }
    }
    for (int i = 1; i < 7; i++) {
        NSTextField *field = [self valueForKey:[NSString stringWithFormat:@"skillKeyField%d", i]];
        CGKeyCode keyCode = [[config valueForKey:[NSString stringWithFormat:@"skillKey%d", i]] unsignedShortValue];
        if (keyCode != 0xFF) {
            field.stringValue = [[D3KeyConfigService sharedService] stringWithKeycode:keyCode];
        } else {
            field.stringValue = @"";
        }
    }
    for (int i = 1; i < 7; i++) {
        NSTextField *field = [self valueForKey:[NSString stringWithFormat:@"skillDelayField%d", i]];
        NSUInteger delay = [[config valueForKey:[NSString stringWithFormat:@"skillDelay%d", i]] unsignedIntegerValue];
        field.stringValue = [NSString stringWithFormat:@"%tu", delay];
    }
    
    NSTextField *field = [self valueForKey:@"mouseLeftDelayField"];
    NSUInteger delay = [[config valueForKey:@"mouseLeftDelay"] unsignedIntegerValue];
    field.stringValue = [NSString stringWithFormat:@"%tu", delay];
    
    field = [self valueForKey:@"mouseRightDelayField"];
    delay = [[config valueForKey:@"mouseRightDelay"] unsignedIntegerValue];
    field.stringValue = [NSString stringWithFormat:@"%tu", delay];
    
    field = [self valueForKey:@"memoField"];
    NSString *memo = [config valueForKey:@"memo"];
    field.stringValue = memo;
    
}

- (D3KeyConfig *) getFieldValues {
    D3KeyConfig *config = [[D3KeyConfig alloc] init];
    if (startKeyField.stringValue) {
        config.startKey = [[D3KeyConfigService sharedService] keyCodeWithString:startKeyField.stringValue];
    }
    
    for (int i = 1; i < 6; i++) {
        NSTextField *field = [self valueForKey:[NSString stringWithFormat:@"stopKeyField%d", i]];
        if (field.stringValue && ![field.stringValue isEqualToString:@"Unknown"]) {
            [config setValue:[NSNumber numberWithUnsignedShort:[[D3KeyConfigService sharedService] keyCodeWithString:field.stringValue]]
                      forKey:[NSString stringWithFormat:@"stopKey%d", i]];
        }
    }
    for (int i = 1; i < 7; i++) {
        NSTextField *field = [self valueForKey:[NSString stringWithFormat:@"skillKeyField%d", i]];
        if (field.stringValue && ![field.stringValue isEqualToString:@"Unknown"]) {
            [config setValue:[NSNumber numberWithUnsignedShort:[[D3KeyConfigService sharedService] keyCodeWithString:field.stringValue]]
                      forKey:[NSString stringWithFormat:@"skillKey%d", i]];
        }
    }
    for (int i = 1; i < 7; i++) {
        NSTextField *field = [self valueForKey:[NSString stringWithFormat:@"skillDelayField%d", i]];
        [config setValue:[NSNumber numberWithUnsignedInteger:[field.stringValue integerValue]]
                  forKey:[NSString stringWithFormat:@"skillDelay%d", i]];
    }
    
    NSTextField *field = [self valueForKey:@"mouseLeftDelayField"];
    [config setValue:[NSNumber numberWithUnsignedInteger:[field.stringValue integerValue]]
              forKey:@"mouseLeftDelay"];
    
    field = [self valueForKey:@"mouseRightDelayField"];
    [config setValue:[NSNumber numberWithUnsignedInteger:[field.stringValue integerValue]]
              forKey:@"mouseRightDelay"];
    
    field = [self valueForKey:@"memoField"];
    [config setValue:field.stringValue
              forKey:@"memo"];
    
    return config;
}

- (void)save {
    NSLog(@"save config");
    NSString *configId = [NSString stringWithFormat:@"%li", configIdSegment.selectedSegment + 1];
    D3KeyConfig *config = [self getFieldValues];
    [[D3KeyConfigService sharedService] saveConfig:config withConfigId:configId];
}

- (void)changePreset:(NSInteger)presetNum {
    configIdSegment.selectedSegment = presetNum;
    NSString *configId = [NSString stringWithFormat:@"%li", presetNum + 1];
    NSLog(@"change configId: %@", configId);
    [self loadConfig:configId];
    [[NSNotificationCenter defaultCenter] postNotificationName:kD3KeyConfigChangedNotification object:nil userInfo:@{@"configId":configId}];
    [[NSNotificationCenter defaultCenter] postNotificationName:kD3KeyStartStopNotification object:nil userInfo:@{@"action": @"stop"}];
}

#pragma mark IBAction

- (IBAction) selectConfigIdSegemnt:(id)sender {
    NSSegmentedControl *control = (NSSegmentedControl *) sender;
    NSString *configId = [NSString stringWithFormat:@"%li", control.selectedSegment + 1];
    NSLog(@"change configId: %@", configId);
    [self loadConfig:configId];
    [[NSNotificationCenter defaultCenter] postNotificationName:kD3KeyConfigChangedNotification object:nil userInfo:@{@"configId":configId}];
    
}

- (IBAction) selectActiveSegment:(id)sender {
    NSSegmentedControl *control = (NSSegmentedControl *) sender;
    if (control.selectedSegment == 0) {
        NSLog(@"activate");
        [[NSNotificationCenter defaultCenter] postNotificationName:kD3KeyActivatedNotification object:nil];
    } else {
        NSLog(@"deactivate");
        [[NSNotificationCenter defaultCenter] postNotificationName:kD3KeyDeactivatedNotification object:nil];
    }
}

#pragma mark NSTextFieldDelegate

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
    if ([control isKindOfClass:[D3KeyTextField class]]) {
        return NO;
    } else {
        return YES;
    }
}

/*
 - (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector {
 BOOL result = NO;
 
 if ([control isKindOfClass:[D3KeyTextField class]]) {
 if (commandSelector == @selector(insertTab:))
 {
 // tab action:
 // always insert a tab character and don’t cause the receiver to end editing
 [textView insertTabIgnoringFieldEditor:self];
 result = YES;
 }
 }
 
 return result;
 }
 */

- (void)controlTextDidChange:(NSNotification *)notification {
    [self save];
}

@end
