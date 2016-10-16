//
//  PointSmoothView.m
//  ES3_2_ES1
//
//  Created by michael on 15/10/2016.
//  Copyright © 2016 jlai. All rights reserved.
//

#import "PointSmoothView.h"

@implementation PointSmoothView

typedef struct {
    GLfloat x, y, z; //position
    GLfloat r, g, b, a; //color and alpha channels
} Vertex;

void drawPoint(Vertex v1, GLfloat size) {
    glPushMatrix();
        glPointSize(size);
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_COLOR_ARRAY);
        glVertexPointer(3, GL_FLOAT, sizeof(Vertex), &v1);
        glColorPointer(4, GL_FLOAT, sizeof(Vertex), &v1.r);
        glDrawArrays(GL_POINTS, 0, 1);
        glDisableClientState(GL_VERTEX_ARRAY);
        glDisableClientState(GL_COLOR_ARRAY);
    glPopMatrix();
}

void drawPointsDemo(int width, int height) {
    GLfloat size = 30.0f;
    for (GLfloat x = -.9f; x <= 1.0f; x += 0.15f, size += 10) {
        Vertex v1 = {x, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f};
        drawPoint(v1, size);
    }
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    [EAGLContext setCurrentContext:context];
    
    CAEAGLLayer *layer = (CAEAGLLayer *) self.layer;
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.opaque = YES;
    
    GLuint renderbuffer;
    glGenRenderbuffersOES(1, &renderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, renderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
    GLint width, height;
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &width);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &height);
    
    GLuint framebuffer;
    glGenFramebuffersOES(1, &framebuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, framebuffer);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, renderbuffer);
    
    glEnable(GL_POINT_SMOOTH);
    glHint(GL_POINT_SMOOTH_HINT, GL_NICEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glViewport(0, 0, width, height);
    glClear(GL_COLOR_BUFFER_BIT);
    
    drawPointsDemo(width, height);
    
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

@end
