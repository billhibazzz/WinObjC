//******************************************************************************
//
// Copyright (c) 2016 Microsoft Corporation. All rights reserved.
//
// This code is licensed under the MIT License (MIT).
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//******************************************************************************

#import <UWP/WindowsStorage.h>

#include <COMIncludes.h>
#include "RawBuffer.h"
#include <COMIncludes_End.h>

#import "ALAssetRepresentationInternal.h"
#import <Starboard.h>
#import <StubReturn.h>
#import <Foundation/NSError.h>
#import <Foundation/NSURL.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

using namespace Microsoft::WRL;
using namespace ABI::Windows::Storage::Streams;

static const wchar_t* TAG = L"ALAssetRepresentation";
NSString* const ALAssetRepresentationDomain = @"ALAssetRepresentation";

// TODO: Task 8286702 - Make createWith public
// Remove once completed
@interface WSSBuffer (ShouldExist)
+ (WSSBuffer*)createWith:(IBuffer*)buffer;
@end
// TODO end

@interface ALAssetRepresentation () {
    StrongId<NSURL> _urlRep;
    StrongId<WSStorageFile> _storageFile;
    uint64_t _fileSize;
}
@end

@implementation ALAssetRepresentation

/**
@Status Interoperable
@Notes Creates single Asset Representation
*/
- (instancetype)_initWithAssetURL:(NSURL*)url localPath:(NSString*)path error:(NSError**)error {
    if ((self = [super init])) {
        _urlRep = url;
        _storageFile = nil;
        __block NSError* tempError = nil;

        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);

        // Make sure the file path is valid and get its StorageFile object
        [WSStorageFile getFileFromPathAsync:path
            success:^void(WSStorageFile* storageFile) {
                _storageFile = storageFile;
                dispatch_group_leave(group);
            }
            failure:^void(NSError* storageError) {
                if (error) {
                    tempError = [storageError copy];
                }
                dispatch_group_leave(group);
            }];

        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        dispatch_release(group);

        if (error) {
            *error = [tempError autorelease];
        }

        if (_storageFile == nil) {
            [self release];
            return nil;
        }
    }
    return self;
}

/**
 @Status Stub
 @Notes
*/
- (CGImageRef)CGImageWithOptions:(NSDictionary*)options {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (CGImageRef)fullResolutionImage {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (CGImageRef)fullScreenImage {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (ALAssetOrientation)orientation {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (float)scale {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (CGSize)dimensions {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (NSString*)filename {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Interoperable
 @Notes Returns the size of the represented file in bytes
*/
- (long long)size {
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);

    [_storageFile getBasicPropertiesAsyncWithSuccess:^void(WSFBasicProperties* basicProperties) {
        _fileSize = [basicProperties size];
        dispatch_group_leave(group);
    }
        failure:^void(NSError* error) {
            _fileSize = 0;
            TraceError(TAG, L"Error getting basic properties of file - %@", error);
            dispatch_group_leave(group);
        }];

    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_release(group);

    return _fileSize;
}

/**
 @Status Interoperable
 @Notes Copy specified bytes into buffer
*/
- (NSUInteger)getBytes:(uint8_t*)buffer fromOffset:(long long)offset length:(NSUInteger)length error:(NSError**)error {
    __block unsigned int bufferLength = 0;
    __block NSError* tempError = nil;

    if (_storageFile) {
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);

        [_storageFile openReadAsyncWithSuccess:^void(RTObject<WSSIRandomAccessStreamWithContentType>* fileStream) {
            [fileStream seek:offset];

            // Create IBuffer from our buffer
            ComPtr<IBuffer> inBuffer;
            HRESULT result = BufferFromRawData(inBuffer.GetAddressOf(), buffer, length);
            THROW_NS_IF_FAILED_MSG(result, "Internal error: Failed to create IBuffer.");
            inBuffer->put_Length(0);

            // Use IBuffer as WSSBuffer to read the stream
            [fileStream readAsync:[WSSBuffer createWith:*(inBuffer.GetAddressOf())]
                count:length
                options:WSSInputStreamOptionsNone
                success:^void(RTObject<WSSIBuffer>* outBuffer) {
                    bufferLength = outBuffer.length;

                    // Get the data buffer out of the com object.
                    ComPtr<IInspectable> insp = [outBuffer comObj];
                    ComPtr<IBufferByteAccess> bufferByteAccess;
                    HRESULT result = insp.As(&bufferByteAccess);
                    THROW_NS_IF_FAILED_MSG(result, "Internal error: Failed to get data from com object.");

                    // Retrieve the buffer data.
                    uint8_t* byteBuffer = nullptr;
                    result = bufferByteAccess->Buffer(&byteBuffer);
                    THROW_NS_IF_FAILED_MSG(result, "Internal error: Failed to retrieve buffer data.");

                    // If readAsync put the data at a different address other than the one passed in,
                    // copy the data into our buffer
                    if (byteBuffer != buffer) {
                        memcpy_s(buffer, length, byteBuffer, bufferLength);
                    }

                    dispatch_group_leave(group);
                }
                progress:^void(unsigned int progress) {

                }
                failure:^void(NSError* fileError) {
                    if (error) {
                        tempError = [fileError copy];
                    }
                    dispatch_group_leave(group);
                }];
        }
            failure:^void(NSError* fileError) {
                if (error) {
                    tempError = [fileError copy];
                }
                dispatch_group_leave(group);
            }];

        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        dispatch_release(group);

        if (error) {
            *error = [tempError autorelease];
        }

    } else {
        if (error) {
            *error = [NSError errorWithDomain:ALAssetRepresentationDomain code:_ALAssetRepresentationErrorCodeFileAccessError userInfo:nil];
        }
    }

    return bufferLength;
}

/**
 @Status Stub
 @Notes
*/
- (NSString*)UTI {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (NSDictionary*)metadata {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Interoperable
 @Notes
*/
- (NSURL*)url {
    return [[_urlRep retain] autorelease];
}

@end
