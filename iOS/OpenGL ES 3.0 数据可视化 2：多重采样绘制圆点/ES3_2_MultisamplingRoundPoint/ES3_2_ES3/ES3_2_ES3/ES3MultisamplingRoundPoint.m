//
//  ES3MultisamplingRoundPoint.m
//  ES3_2_ES3
//
//  Created by michael on 16/10/2016.
//  Copyright © 2016 jlai. All rights reserved.
//

#import "ES3MultisamplingRoundPoint.h"
#import <OpenGLES/ES3/gl.h>

@interface ES3MultisamplingRoundPoint () {
    EAGLContext *context;
    CAEAGLLayer *layer;
    GLint width, height;
    GLuint msaaRenderbuffer[1], msaaFramebuffer[1];
    GLuint defaultRenderbuffer[1], defaultFramebuffer[1];
    
    CADisplayLink *freshTimer;
}

@end

@implementation ES3MultisamplingRoundPoint

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:context];
    
    layer = (CAEAGLLayer *)self.layer;
    layer.opaque = YES;
    layer.contentsScale = [UIScreen mainScreen].scale;
    
    GLint maxSupportSamples;
    glGetIntegerv(GL_MAX_SAMPLES, &maxSupportSamples);
    printf("max support samples = %d\n", maxSupportSamples);
    
    glGenRenderbuffers(1, defaultRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, defaultRenderbuffer[0]);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    glGenFramebuffers(1, defaultFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer[0]);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, defaultRenderbuffer[0]);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    glGenRenderbuffers(1, msaaRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, msaaRenderbuffer[0]);
    glRenderbufferStorageMultisample(GL_RENDERBUFFER, 4, GL_RGBA8, width, height);
    
    glGenFramebuffers(1, msaaFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, msaaFramebuffer[0]);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, msaaRenderbuffer[0]);
    
    // Test the framebuffer for completeness.
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
    //
    char *vertexShaderContent = "#version 300 es \n"
    "layout(location = 0) in vec4 vin_position; \n"
    "layout(location = 1) in float vin_point_size; \n"
    "void main() { \n"
    "    gl_PointSize = vin_point_size; \n"
    "    gl_Position = vin_position;} \n";
     GLuint vertexShader = compileShader(vertexShaderContent, GL_VERTEX_SHADER);
    
    char *fragmentShaderContent = "#version 300 es \n"
    "precision highp float; \n"
    "out vec4 fout_color; \n"
    "void main() { \n"
    "    if (length(gl_PointCoord - vec2(0.5)) > 0.5) { discard; }\n"
    "    fout_color = vec4(1.0, 1.0, 1.0, 1.0);} \n";
    GLuint fragmentShader = compileShader(fragmentShaderContent, GL_FRAGMENT_SHADER);
    
    //
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    glLinkProgram(program);
    GLint linkStatus;
    glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLint infoLength;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLength);
        if (infoLength > 0) {
            GLchar *infoLog = malloc(sizeof(GLchar) * infoLength);
            glGetProgramInfoLog(program, infoLength, NULL, infoLog);
            printf("%s\n", infoLog);
            free(infoLog);
        }
    }
    
    glUseProgram(program);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glClearColor(0, 0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, width, height);
    
    if (!freshTimer) {
        freshTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(draw)];
        [freshTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)draw {
    glBindFramebuffer(GL_FRAMEBUFFER, msaaFramebuffer[0]);
    glBindRenderbuffer(GL_RENDERBUFFER, msaaRenderbuffer[0]);
    
    GLfloat vertex[2];
    GLfloat size[] = {50.f};
    for (GLfloat i = -0.9; i <= 1.0; i += 0.25f, size[0] += 20) {
        vertex[0] = i;
        vertex[1] = 0.f;
        
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 2/* 坐标分量个数 */, GL_FLOAT, GL_FALSE, 0, vertex);
        
        glEnableVertexAttribArray(1);
        glVertexAttribPointer(1, 1, GL_FLOAT, GL_FALSE, 0, size);
        
        glDrawArrays(GL_POINTS, 0, 1);
    }
    
    glBindFramebuffer(GL_READ_FRAMEBUFFER, msaaFramebuffer[0]);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, defaultFramebuffer[0]);
    glBlitFramebuffer(0, 0, width, height,
                      0, 0, width, height,
                      GL_COLOR_BUFFER_BIT,
                      GL_LINEAR);
    
    glBindRenderbuffer(GL_RENDERBUFFER, defaultRenderbuffer[0]);
    [context presentRenderbuffer:GL_RENDERBUFFER];

}

GLuint compileShader(char *shaderContent, GLenum shaderType) {
    GLuint shader = glCreateShader(shaderType);
    glShaderSource(shader, 1, &shaderContent, NULL);
    glCompileShader(shader);
    
    GLint compileStatus;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileStatus);
    if (compileStatus == GL_FALSE) {
        GLint infoLength;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLength);
        if (infoLength > 0) {
            GLchar *infoLog = malloc(sizeof(GLchar) * infoLength);
            glGetShaderInfoLog(shader, infoLength, NULL, infoLog);
            printf("%s -> %s\n", shaderType == GL_VERTEX_SHADER ? "vertex shader" : "fragment shader", infoLog);
            free(infoLog);
        }
    }
    return shader;
}

@end
