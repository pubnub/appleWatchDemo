#import <Foundation/Foundation.h>


/**
 @brief      Model representation helper class.
 @discussion This class provide ability to represent model as dictionary so it will be possible to 
             send it elsewhere using JSON serialization.
             Class also provide methods to create object instance back from dictionary 
             representation.

 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface SPNPSerializable : NSObject


///------------------------------------------------
/// @name Serialization
///------------------------------------------------

/**
 @brief  Serialize model object to dictionary.
 
 @return Dictionary object representation.
 */
- (NSDictionary *)dictionaryRepresentation;

/**
 @brief  Allow subclass to pass list of property names which shouldn't be used during object
         serialization.
 
 @return List of ignored property list names.
 */
- (NSArray *)ignoredProperties;


///------------------------------------------------
/// @name Deserialization
///------------------------------------------------

/**
 @brief  Create model class from it's dictionary representation.
 
 @param data Model dictionary representation.
 
 @return Initialized and ready to use model instance restored from dictionary.
 */
+ (instancetype)objectFromDictionaryRepresentation:(NSDictionary *)data;

#pragma mark -

@end
