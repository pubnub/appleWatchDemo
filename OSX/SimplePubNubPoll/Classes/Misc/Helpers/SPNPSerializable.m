/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "SPNPSerializable.h"
#import <objc/runtime.h>


#pragma mark Private interface declaration

@interface SPNPSerializable ()


#pragma mark - Instance variables

/**
 @brief  Retrieve list of properties which should be serialized into dictionary.
 
 @return List of property variable names.
 
 @since 1.0
 */
- (NSArray *)properties;


#pragma mark - Serialization

/**
 @breif  Try to serialize passed value to format which can be placed into dictionary and encoded to
         JSON string.
 
 @param value Reference on value which should be serialized.
 
 @return Serialized value.
 */
- (id)serializedValue:(id)value;

/**
 @brief  Try to serialize collection instance elements and return new collection with serialized
         content.
 
 @param collection Reference on \c NSArray or \c NSDictionary who's content should be serialized.
 
 @return New collection of same type as \c collection with correctly serialized content.
 */
- (id)serializedCollection:(id)collection;


#pragma mark - Deserialization

/**
 @breif  Try to de-serialize passed by extracting it's internal content if it can be deserialized to
         object using this helper class.
 
 @param value Reference on value which should be serialized.
 
 @return De-serialized value.
 */
+ (id)deserializedValue:(id)value;

/**
 @brief  Try to de-serialize collection instance elements and return new collection with 
         de-serialized content.
 
 @param collection Reference on \c NSArray or \c NSDictionary who's content should be serialized.
 
 @return New collection of same type as \c collection with correctly de-serialized content.
 */
+ (id)deserializedCollection:(id)collection;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation SPNPSerializable


#pragma mark - Serialization

- (NSDictionary *)dictionaryRepresentation {
    
    NSMutableDictionary *dictionary = [@{@"s_class": NSStringFromClass(self.class)} mutableCopy];
    NSArray *properties = [self properties];
    for (NSString *propertyName in properties) {
        
        id propertyValue = [self serializedValue:[self valueForKey:propertyName]];
        if (propertyValue) { dictionary[propertyName] = propertyValue; }
    }
    
    return (dictionary.count ? dictionary : nil);
}

- (NSArray *)ignoredProperties {
    
    return nil;
}

- (id)serializedValue:(id)value {
    
    return ([value respondsToSelector:@selector(count)] ? [self serializedCollection:value] : value);
}

- (id)serializedCollection:(id)collection {
    
    id serializedCollection = nil;
    id(^serializationBlock)(id value) = ^id(id value) {
        
        id serializedValue = value;
        if (![value respondsToSelector:@selector(dictionaryRepresentation)]) {
            
            serializedValue = [self serializedValue:value];
        }
        else { serializedValue = [value dictionaryRepresentation]; }
        
        return serializedValue;
    };
    
    if ([collection isKindOfClass:NSArray.class]) {
        
        serializedCollection = [NSMutableArray new];
        [(NSArray *)collection enumerateObjectsUsingBlock:^(id object, NSUInteger objectIdx,
                                                            BOOL *objectsEnumeratorStop) {
            
            [(NSMutableArray *)serializedCollection addObject:serializationBlock(object)];
        }];
    }
    else if ([collection isKindOfClass:NSDictionary.class]) {
        
        serializedCollection = [NSMutableDictionary new];
        [(NSDictionary *)collection enumerateKeysAndObjectsUsingBlock:^(id  objectKey, id object,
                                                                        BOOL *objectsEnumeratorStop) {
            
            [(NSMutableDictionary *)serializedCollection setValue:serializationBlock(object)
                                                           forKey:objectKey];
        }];
    }
    
    return serializedCollection;
}


#pragma mark - Deserialization

+ (instancetype)objectFromDictionaryRepresentation:(NSDictionary *)data {
    
    id object = nil;
    if (data && [NSStringFromClass(self.class) isEqualToString:data[@"s_class"]]) {
        
        object = [self new];
        for (NSString *propertyName in data.allKeys) {
            
            if (![propertyName isEqualToString:@"s_class"]) {
                
                id propertyValue = [self deserializedValue:data[propertyName]];
                if (propertyValue) { [object setValue:propertyValue forKey:propertyName]; }
            }
        }
    }
    
    return object;
}

+ (id)deserializedValue:(id)value {
    
    id deserializedValue = value;
    if ([value respondsToSelector:@selector(count)]) {
        
        if ([value isKindOfClass:NSDictionary.class] && value[@"s_class"] != nil) {
            
            deserializedValue = [NSClassFromString(value[@"s_class"]) objectFromDictionaryRepresentation:value];
        }
        else { deserializedValue = [self deserializedCollection:value]; }
    }
    
    return deserializedValue;
}

+ (id)deserializedCollection:(id)collection {
    
    id deserializedCollection = nil;
    if ([collection isKindOfClass:NSArray.class]) {
        
        deserializedCollection = [NSMutableArray new];
        [(NSArray *)collection enumerateObjectsUsingBlock:^(id object, NSUInteger objectIdx,
                                                            BOOL *objectsEnumeratorStop) {
            
            [(NSMutableArray *)deserializedCollection addObject:[self deserializedValue:object]];
        }];
    }
    else if ([collection isKindOfClass:NSDictionary.class]) {
        
        deserializedCollection = [NSMutableDictionary new];
        [(NSDictionary *)collection enumerateKeysAndObjectsUsingBlock:^(id  objectKey, id object,
                                                                        BOOL *objectsEnumeratorStop) {
            
            [(NSMutableDictionary *)deserializedCollection setValue:[self deserializedValue:object]
                                                             forKey:objectKey];
        }];
    }
    
    return deserializedCollection;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    // Do nothing.
}


#pragma mark - Properties access

- (NSArray *)properties {
    
    unsigned int propertiesCount;
    objc_property_t *property_structures = class_copyPropertyList(self.class, &propertiesCount);
    
    NSMutableArray *properties = [NSMutableArray arrayWithCapacity:propertiesCount];
    NSArray *ignoredProperties = [self ignoredProperties];
    for (NSUInteger propertyIdx = 0; propertyIdx < propertiesCount; propertyIdx++) {
        
        objc_property_t property = property_structures[propertyIdx];
        NSString *propertyName = [NSString stringWithFormat:@"%s", property_getName(property)];
        if (![ignoredProperties containsObject:propertyName]) {
            
            [properties addObject:propertyName];
        }
    }
    free(property_structures);
    
    return [properties copy];
}

#pragma mark -


@end
