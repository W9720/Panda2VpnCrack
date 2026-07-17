#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <substrate.h>

#define kExpireDate @"2099.12.31"
#define kRemainingDays @"9999"
#define kPlanStatus @"Premium"

@interface _TtC9Panda2Vpn8ProfileV : NSObject
@property (nonatomic, weak) UILabel *endDateL;
@property (nonatomic, weak) UILabel *ddayL;
@property (nonatomic, weak) UILabel *planL;
@end

@interface _TtC9Panda2Vpn7MyInfoV : NSObject
@property (nonatomic, weak) UILabel *endDateL;
@end

@interface _TtC9Panda2Vpn12UserInfoData : NSObject
@property (nonatomic, strong) id myInfoData;
@property (nonatomic, strong) NSArray *payInfoList;
@end

static void (*orig_ProfileV_setEndDateL)(_TtC9Panda2Vpn8ProfileV *, SEL, UILabel *);
static void (*orig_ProfileV_setDdayL)(_TtC9Panda2Vpn8ProfileV *, SEL, UILabel *);
static void (*orig_MyInfoV_setEndDateL)(_TtC9Panda2Vpn7MyInfoV *, SEL, UILabel *);

static void ProfileV_setEndDateL_hook(_TtC9Panda2Vpn8ProfileV *self, SEL _cmd, UILabel *label) {
    orig_ProfileV_setEndDateL(self, _cmd, label);
    if (label) {
        label.text = kExpireDate;
    }
}

static void ProfileV_setDdayL_hook(_TtC9Panda2Vpn8ProfileV *self, SEL _cmd, UILabel *label) {
    orig_ProfileV_setDdayL(self, _cmd, label);
    if (label) {
        label.text = kRemainingDays;
    }
}

static void MyInfoV_setEndDateL_hook(_TtC9Panda2Vpn7MyInfoV *self, SEL _cmd, UILabel *label) {
    orig_MyInfoV_setEndDateL(self, _cmd, label);
    if (label) {
        label.text = kExpireDate;
    }
}

static void (*orig_ProfileV_viewSetting)(_TtC9Panda2Vpn8ProfileV *, SEL);
static void ProfileV_viewSetting_hook(_TtC9Panda2Vpn8ProfileV *self, SEL _cmd) {
    orig_ProfileV_viewSetting(self, _cmd);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.endDateL) {
            self.endDateL.text = kExpireDate;
        }
        if (self.ddayL) {
            self.ddayL.text = kRemainingDays;
        }
        if (self.planL) {
            self.planL.text = kPlanStatus;
        }
    });
}

static void (*orig_NSObject_setValueForKey)(id, SEL, id, NSString*);
static void NSObject_setValueForKey_hook(id self, SEL _cmd, id value, NSString *key) {
    NSString *lowerKey = [key lowercaseString];
    
    if ([lowerKey containsString:@"enddate"] || 
        [lowerKey containsString:@"end_date"] || 
        [lowerKey containsString:@"expiredate"] ||
        [lowerKey containsString:@"expire_date"] ||
        [lowerKey containsString:@"expiredatetime"]) {
        value = kExpireDate;
    } else if ([lowerKey containsString:@"dday"] || 
               [lowerKey containsString:@"d_day"] || 
               [lowerKey containsString:@"remainingdays"] ||
               [lowerKey containsString:@"remaining_days"]) {
        value = kRemainingDays;
    } else if ([lowerKey containsString:@"plan"] || 
               [lowerKey containsString:@"status"] ||
               [lowerKey containsString:@"level"] ||
               [lowerKey containsString:@"vip"]) {
        if ([value isKindOfClass:[NSString class]]) {
            value = kPlanStatus;
        }
    }
    
    orig_NSObject_setValueForKey(self, _cmd, value, key);
}

static void (*orig_NSObject_setValueForKeyPath)(id, SEL, id, NSString*);
static void NSObject_setValueForKeyPath_hook(id self, SEL _cmd, id value, NSString *keyPath) {
    NSString *lowerKey = [keyPath lowercaseString];
    
    if ([lowerKey containsString:@"enddate"] || 
        [lowerKey containsString:@"expiredate"] ||
        [lowerKey containsString:@"dday"] ||
        [lowerKey containsString:@"remainingdays"]) {
        
        NSArray *components = [keyPath componentsSeparatedByString:@"."];
        NSString *lastKey = [components lastObject];
        
        if ([[lastKey lowercaseString] containsString:@"enddate"] ||
            [[lastKey lowercaseString] containsString:@"expiredate"]) {
            value = kExpireDate;
        } else if ([[lastKey lowercaseString] containsString:@"dday"] ||
                   [[lastKey lowercaseString] containsString:@"remainingdays"]) {
            value = kRemainingDays;
        }
    }
    
    orig_NSObject_setValueForKeyPath(self, _cmd, value, keyPath);
}

static id (*orig_NSObject_valueForKey)(id, SEL, NSString*);
static id NSObject_valueForKey_hook(id self, SEL _cmd, NSString *key) {
    id result = orig_NSObject_valueForKey(self, _cmd, key);
    
    NSString *lowerKey = [key lowercaseString];
    
    if ([lowerKey containsString:@"enddate"] || 
        [lowerKey containsString:@"end_date"] || 
        [lowerKey containsString:@"expiredate"] ||
        [lowerKey containsString:@"expire_date"]) {
        return kExpireDate;
    } else if ([lowerKey containsString:@"dday"] || 
               [lowerKey containsString:@"d_day"] || 
               [lowerKey containsString:@"remainingdays"] ||
               [lowerKey containsString:@"remaining_days"]) {
        return kRemainingDays;
    }
    
    return result;
}

static void (*orig_UILabel_setText)(UILabel *, SEL, NSString*);
static void UILabel_setText_hook(UILabel *self, SEL _cmd, NSString *text) {
    if (text && [text length] > 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy.MM.dd"];
        NSDate *date = [dateFormatter dateFromString:text];
        
        if (date) {
            text = kExpireDate;
        } else {
            NSCharacterSet *numberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
            NSRange range = [text rangeOfCharacterFromSet:numberSet];
            
            if (range.location != NSNotFound) {
                NSString *numberString = [[text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                
                if ([numberString length] > 0 && [numberString intValue] > 0 && [numberString intValue] < 9999) {
                    if ([text containsString:@"day"] || 
                        [text containsString:@"Day"] ||
                        [text containsString:@"剩余"] ||
                        [text containsString:@"天"]) {
                        text = kRemainingDays;
                    }
                }
            }
        }
    }
    
    orig_UILabel_setText(self, _cmd, text);
}

__attribute__((constructor)) static void Panda2VpnCrack_init() {
    NSLog(@"[Panda2VpnCrack] Loading...");
    
    Class ProfileV = objc_getClass("_TtC9Panda2Vpn8ProfileV");
    Class MyInfoV = objc_getClass("_TtC9Panda2Vpn7MyInfoV");
    
    if (ProfileV) {
        SEL setEndDateL_sel = NSSelectorFromString(@"setEndDateL:");
        SEL setDdayL_sel = NSSelectorFromString(@"setDdayL:");
        SEL viewSetting_sel = NSSelectorFromString(@"viewSetting");
        
        if (class_getInstanceMethod(ProfileV, setEndDateL_sel)) {
            MSHookMessageEx(ProfileV, setEndDateL_sel, (IMP)ProfileV_setEndDateL_hook, (IMP*)&orig_ProfileV_setEndDateL);
            NSLog(@"[Panda2VpnCrack] Hooked ProfileV setEndDateL:");
        }
        
        if (class_getInstanceMethod(ProfileV, setDdayL_sel)) {
            MSHookMessageEx(ProfileV, setDdayL_sel, (IMP)ProfileV_setDdayL_hook, (IMP*)&orig_ProfileV_setDdayL);
            NSLog(@"[Panda2VpnCrack] Hooked ProfileV setDdayL:");
        }
        
        if (class_getInstanceMethod(ProfileV, viewSetting_sel)) {
            MSHookMessageEx(ProfileV, viewSetting_sel, (IMP)ProfileV_viewSetting_hook, (IMP*)&orig_ProfileV_viewSetting);
            NSLog(@"[Panda2VpnCrack] Hooked ProfileV viewSetting");
        }
    }
    
    if (MyInfoV) {
        SEL setEndDateL_sel = NSSelectorFromString(@"setEndDateL:");
        
        if (class_getInstanceMethod(MyInfoV, setEndDateL_sel)) {
            MSHookMessageEx(MyInfoV, setEndDateL_sel, (IMP)MyInfoV_setEndDateL_hook, (IMP*)&orig_MyInfoV_setEndDateL);
            NSLog(@"[Panda2VpnCrack] Hooked MyInfoV setEndDateL:");
        }
    }
    
    MSHookMessageEx([NSObject class], @selector(setValue:forKey:), (IMP)NSObject_setValueForKey_hook, (IMP*)&orig_NSObject_setValueForKey);
    NSLog(@"[Panda2VpnCrack] Hooked NSObject setValue:forKey:");
    
    MSHookMessageEx([NSObject class], @selector(setValue:forKeyPath:), (IMP)NSObject_setValueForKeyPath_hook, (IMP*)&orig_NSObject_setValueForKeyPath);
    NSLog(@"[Panda2VpnCrack] Hooked NSObject setValue:forKeyPath:");
    
    MSHookMessageEx([NSObject class], @selector(valueForKey:), (IMP)NSObject_valueForKey_hook, (IMP*)&orig_NSObject_valueForKey);
    NSLog(@"[Panda2VpnCrack] Hooked NSObject valueForKey:");
    
    MSHookMessageEx([UILabel class], @selector(setText:), (IMP)UILabel_setText_hook, (IMP*)&orig_UILabel_setText);
    NSLog(@"[Panda2VpnCrack] Hooked UILabel setText:");
    
    NSLog(@"[Panda2VpnCrack] Loaded successfully!");
}
