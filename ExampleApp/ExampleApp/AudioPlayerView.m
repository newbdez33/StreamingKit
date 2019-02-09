/**********************************************************************************
 AudioPlayer.m
 
 Created by Thong Nguyen on 14/05/2012.
 https://github.com/tumtumtum/audjustable
 
 Copyright (c) 2012 Thong Nguyen (tumtumtum@gmail.com). All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 1. Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 3. All advertising materials mentioning features or use of this software
 must display the following acknowledgement:
 This product includes software developed by Thong Nguyen (tumtumtum@gmail.com)
 4. Neither the name of Thong Nguyen nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY Thong Nguyen ''AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THONG NGUYEN BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **********************************************************************************/

#import "AudioPlayerView.h"
#import "SampleQueueId.h"

///
/// This sample media player will play a local or an HTTP stream in repeat (gapless)
///

@interface AudioPlayerView()
-(void) setupTimer;
-(void) updateControls;
@end

@implementation AudioPlayerView
@synthesize audioPlayer, delegate;

- (id)initWithFrame:(CGRect)frame andAudioPlayer:(STKAudioPlayer*)audioPlayerIn
{
    self = [super initWithFrame:frame];
	
    if (self)
	{
        hzs = @[@50, @100, @200, @400, @800, @1600, @2600, @16000];
        
        self.audioPlayer = audioPlayerIn;
        
		CGSize size = CGSizeMake(220, 50);
		
        
		playFromHTTPButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		playFromHTTPButton.frame = CGRectMake((frame.size.width - size.width) / 2, frame.size.height * 0.10, size.width, size.height);
		[playFromHTTPButton addTarget:self action:@selector(playFromHTTPButtonTouched) forControlEvents:UIControlEventTouchUpInside];
		[playFromHTTPButton setTitle:@"Play from HTTP" forState:UIControlStateNormal];
        
         self.textField = [[UITextField alloc] initWithFrame:CGRectMake(40, 40, self.bounds.size.width - 80, 30)];
         self.textField.layer.borderWidth = 1;
        self.textField.font = [UIFont systemFontOfSize:12];
         self.textField.layer.borderColor = UIColor.lightGrayColor.CGColor;
        //http://audio.checked.fm/Checked-37.mp3?_=1
        //https://karenandellen.podbean.com/mf/download/p29i9w/KE_Ep12.m4a
        self.textField.text = @"https://karenandellen.podbean.com/mf/download/p29i9w/KE_Ep12.m4a";
        [self addSubview: self.textField];
        
        playFromIcecastButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        playFromIcecastButton.frame = CGRectMake((frame.size.width - size.width) / 2, frame.size.height * 0.10 + 35, size.width, size.height);
        [playFromIcecastButton addTarget:self action:@selector(playFromIcecasButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [playFromIcecastButton setTitle:@"Play from Icecast" forState:UIControlStateNormal];
        playFromIcecastButton.hidden = YES;
		playFromLocalFileButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		playFromLocalFileButton.frame = CGRectMake((frame.size.width - size.width) / 2, frame.size.height * 0.10 + 70, size.width, size.height);
		[playFromLocalFileButton addTarget:self action:@selector(playFromLocalFileButtonTouched) forControlEvents:UIControlEventTouchUpInside];
		[playFromLocalFileButton setTitle:@"Play from Local File" forState:UIControlStateNormal];
        playFromLocalFileButton.hidden = YES;
        queueShortFileButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		queueShortFileButton.frame = CGRectMake((frame.size.width - size.width) / 2, frame.size.height * 0.10 + 105, size.width, size.height);
		[queueShortFileButton addTarget:self action:@selector(queueShortFileButtonTouched) forControlEvents:UIControlEventTouchUpInside];
		[queueShortFileButton setTitle:@"Queue short file" forState:UIControlStateNormal];
		queueShortFileButton.hidden = YES;
		queuePcmWaveFileFromHTTPButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		queuePcmWaveFileFromHTTPButton.frame = CGRectMake((frame.size.width - size.width) / 2, frame.size.height * 0.10 + 140, size.width, size.height);
		[queuePcmWaveFileFromHTTPButton addTarget:self action:@selector(queuePcmWaveFileButtonTouched) forControlEvents:UIControlEventTouchUpInside];
		[queuePcmWaveFileFromHTTPButton setTitle:@"Queue PCM/WAVE from HTTP" forState:UIControlStateNormal];
        queuePcmWaveFileFromHTTPButton.hidden = YES;
        size = CGSizeMake(90, 40);
        
		playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		playButton.frame = CGRectMake(30, 400, size.width, size.height);
		[playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        stopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		stopButton.frame = CGRectMake((frame.size.width - size.width) - 30, 400, size.width, size.height);
		[stopButton addTarget:self action:@selector(stopButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [stopButton setTitle:@"Stop" forState:UIControlStateNormal];
		
		muteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		muteButton.frame = CGRectMake((frame.size.width - size.width) - 30, 430, size.width, size.height);
		[muteButton addTarget:self action:@selector(muteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		[muteButton setTitle:@"Mute" forState:UIControlStateNormal];
		
		slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 300, queuePcmWaveFileFromHTTPButton.frame.origin.y + queuePcmWaveFileFromHTTPButton.frame.size.height + 20, 20)];
		slider.continuous = YES;
		[slider addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];

        //playbackspeed Slider
        playbackspeedslider = [[UISlider alloc] initWithFrame:CGRectMake(20, 330, queuePcmWaveFileFromHTTPButton.frame.origin.y + queuePcmWaveFileFromHTTPButton.frame.size.height + 20, 20)];
        playbackspeedslider.hidden = YES;
        playbackspeedslider.continuous = YES;
        [playbackspeedslider addTarget:self action:@selector(playbackspeed) forControlEvents:UIControlEventValueChanged];
        
        //Set PlaybackSpeed range and initial value
        playbackspeedslider.minimumValue=0.5;
        playbackspeedslider.maximumValue=2;
        playbackspeedslider.value=1;
        
        
        NSArray *eqs = @[@(-27), @(10), @(20), @(24), @(22), @(24), @(13), @(-15)];
        for (int i=0; i<hzs.count; i++) {
            UILabel * lab = [[UILabel alloc] initWithFrame:CGRectMake(20, 500 + i * 35, 50, 30)];
            lab.text = [NSString stringWithFormat:@"%@ hz", hzs[i]];
            lab.font = [UIFont systemFontOfSize:10];
            [self addSubview:lab];
            UISlider * item = [[UISlider alloc] initWithFrame:CGRectMake(70, 500 + i * 35, 280, 30)];
            item.minimumValue = -96;
            item.maximumValue = 24;
            item.continuous = NO;
            NSNumber * eq = eqs[i];
            item.value = eq.integerValue;
            item.tag = 1000+i;
            [item addTarget:self action:@selector(eqChanged) forControlEvents:UIControlEventValueChanged];
            [self addSubview:item];
        }
        eqlabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 500 + 8 * 35, 300, 30)];
        eqlabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:eqlabel];
        [self eqChanged];
        
        
        size = CGSizeMake(80, 50);
        
        repeatSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(30, frame.size.height * 0.15 + 180, size.width, size.height)];
        repeatSwitch.hidden = YES;
        enableEqSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(frame.size.width - size.width - 30, 180, size.width, size.height)];
        enableEqSwitch.on = audioPlayer.equalizerEnabled;
        //enableEqSwitch.hidden = YES;
        [enableEqSwitch addTarget:self action:@selector(onEnableEqSwitch) forControlEvents:UIControlEventAllTouchEvents];

        label = [[UILabel alloc] initWithFrame:CGRectMake(0, slider.frame.origin.y + slider.frame.size.height + 40, frame.size.width, 25)];
		
        label.textAlignment = NSTextAlignmentCenter;
        
        //playbackspeedlabel
        self.playbackspeedlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, playbackspeedslider.frame.origin.y + playbackspeedslider.frame.size.height + 40, frame.size.width, 25)];
        
        self.playbackspeedlabel.textAlignment = NSTextAlignmentCenter;
        
        
        statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, slider.frame.origin.y + slider.frame.size.height + label.frame.size.height + 50, frame.size.width, 50)];
		
        statusLabel.textAlignment = NSTextAlignmentCenter;
		
		meter = [[UIView alloc] initWithFrame:CGRectMake(0, 450, 0, 20)];
		
		meter.backgroundColor = [UIColor greenColor];
		
		[self addSubview:slider];
        //playbackspeedslider
        [self addSubview:playbackspeedslider];
		[self addSubview:playButton];
		[self addSubview:playFromHTTPButton];
        [self addSubview:playFromIcecastButton];
		[self addSubview:playFromLocalFileButton];
        [self addSubview:queueShortFileButton];
		[self addSubview:queuePcmWaveFileFromHTTPButton];
        [self addSubview:repeatSwitch];
        [self addSubview:label];
        //playbackspeedlabel
        [self addSubview:self.playbackspeedlabel];
        [self addSubview:statusLabel];
        [self addSubview:stopButton];
		[self addSubview:meter];
		[self addSubview:muteButton];
        [self addSubview:enableEqSwitch];
        
		[self setupTimer];
		[self updateControls];
    }
	
    return self;
}

- (void) eqChanged {
    NSMutableString * str = [NSMutableString new];
    [str appendString:@"EQ:"];
    for (int i=0; i<hzs.count; i++) {
        UISlider * item = [self viewWithTag:1000+i];
        [audioPlayer setGain:@(item.value).integerValue forEqualizerBand:i];
        NSLog(@"%@ = %@", hzs[i], @(item.value));
        [str appendString:[NSString stringWithFormat:@"%@", @(@(item.value).integerValue)]];
        if ( i < hzs.count - 1) {
            [str appendString:@","];
        }
    }
    eqlabel.text = str;
}

-(void) onEnableEqSwitch
{
    audioPlayer.equalizerEnabled = self->enableEqSwitch.on;

}

-(void) sliderChanged
{
	if (!audioPlayer)
	{
		return;
	}
	
	NSLog(@"Slider Changed: %f", slider.value);
	
	[audioPlayer seekToTime:slider.value];
}

-(void) playbackspeed{

    // Set PlaybackSpeedValue; Allows continuous float values from 0.5x to 2x
    [audioPlayer setplaybackbackspeed:(AudioUnitParameterValue) playbackspeedslider.value];

}


-(void) setupTimer
{
	timer = [NSTimer timerWithTimeInterval:0.001 target:self selector:@selector(tick) userInfo:nil repeats:YES];
	
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void) tick
{
    
    
	if (!audioPlayer)
	{
		slider.value = 0;
        label.text = @"";
        statusLabel.text = @"";
        //playbackspeedlabel
		self.playbackspeedlabel.text=@"";
		return;
	}
	
    if (audioPlayer.currentlyPlayingQueueItemId == nil)
    {
        slider.value = 0;
        slider.minimumValue = 0;
        slider.maximumValue = 0;
        
        label.text = @"";
        //playbackspeedlabel
        self.playbackspeedlabel.text=@"";
        return;
    }
    
    if (audioPlayer.duration != 0)
    {
        slider.minimumValue = 0;
        slider.maximumValue = audioPlayer.duration;
        slider.value = audioPlayer.progress;
        
        label.text = [NSString stringWithFormat:@"%@ - %@", [self formatTimeFromSeconds:audioPlayer.progress], [self formatTimeFromSeconds:audioPlayer.duration]];
        
        //playbackspeedlabel
        //self.playbackspeedlabel.text=[[NSString alloc] initWithFormat:@"%0.3fx", playbackspeedslider.value];
    }
    else
    {
        slider.value = 0;
        slider.minimumValue = 0;
        slider.maximumValue = 0;
        
        label.text =  [NSString stringWithFormat:@"Live stream %@", [self formatTimeFromSeconds:audioPlayer.progress]];
    }
    
    statusLabel.text = audioPlayer.state == STKAudioPlayerStateBuffering ? @"buffering" : @"";
	
	CGFloat newWidth = 320 * (([audioPlayer averagePowerInDecibelsForChannel:1] + 60) / 60);
	
	meter.frame = CGRectMake(0, 460, newWidth, 20);
    
}

-(void) playFromHTTPButtonTouched
{
    [self.textField resignFirstResponder];
	[self.delegate audioPlayerViewPlayFromHTTPSelected:self];
}

-(void) playFromIcecasButtonTouched
{
    [self.delegate audioPlayerViewPlayFromIcecastSelected:self];
}

-(void) playFromLocalFileButtonTouched
{
	[self.delegate audioPlayerViewPlayFromLocalFileSelected:self];
}

-(void) queueShortFileButtonTouched
{
	[self.delegate audioPlayerViewQueueShortFileSelected:self];
}

-(void) queuePcmWaveFileButtonTouched
{
	[self.delegate audioPlayerViewQueuePcmWaveFileSelected:self];
}

-(void) muteButtonPressed
{
	audioPlayer.muted = !audioPlayer.muted;
	
	if (audioPlayer.muted)
	{
		[muteButton setTitle:@"Unmute" forState:UIControlStateNormal];
	}
	else
	{
		[muteButton setTitle:@"Mute" forState:UIControlStateNormal];
	}
}

-(void) stopButtonPressed
{
    [audioPlayer stop];
}

-(void) playButtonPressed
{
	if (!audioPlayer)
	{
		return;
	}
    
	if (audioPlayer.state == STKAudioPlayerStatePaused)
	{
		[audioPlayer resume];
	}
	else
	{
		[audioPlayer pause];
	}
}

-(NSString*) formatTimeFromSeconds:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

-(void) updateControls
{
	if (audioPlayer == nil)
	{
		[playButton setTitle:@"" forState:UIControlStateNormal];
	}
	else if (audioPlayer.state == STKAudioPlayerStatePaused)
	{
		[playButton setTitle:@"Resume" forState:UIControlStateNormal];
	}
	else if (audioPlayer.state & STKAudioPlayerStatePlaying)
	{
		[playButton setTitle:@"Pause" forState:UIControlStateNormal];
	}
	else
	{
		[playButton setTitle:@"" forState:UIControlStateNormal];
	}
    
    [self tick];
}

-(void) setAudioPlayer:(STKAudioPlayer*)value
{
	if (audioPlayer)
	{
		audioPlayer.delegate = nil;
	}
    

	audioPlayer = value;
	audioPlayer.delegate = self;
    
    [audioPlayer appendFrameFilterWithName:@"MyCustomFilter" block:^(UInt32 channelsPerFrame, UInt32 bytesPerFrame, UInt32 frameCount, void* frames)
    {
        //NSLog(@"%@", @(frameCount));
    }];
	
	[self updateControls];
}

-(STKAudioPlayer*) audioPlayer
{
	return audioPlayer;
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{
	[self updateControls];
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
	[self updateControls];
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
	SampleQueueId* queueId = (SampleQueueId*)queueItemId;
    
    NSLog(@"Started: %@", [queueId.url description]);
    
	[self updateControls];
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId
{
	[self updateControls];
    
    // This queues on the currently playing track to be buffered and played immediately after (gapless)
    
    if (repeatSwitch.on)
    {
        SampleQueueId* queueId = (SampleQueueId*)queueItemId;

        NSLog(@"Requeuing: %@", [queueId.url description]);

        [self->audioPlayer queueDataSource:[STKAudioPlayer dataSourceFromURL:queueId.url] withQueueItemId:[[SampleQueueId alloc] initWithUrl:queueId.url andCount:queueId.count + 1]];
    }
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
	[self updateControls];
 
    SampleQueueId* queueId = (SampleQueueId*)queueItemId;
    
    NSLog(@"Finished: %@", [queueId.url description]);
}

-(void) audioPlayer:(STKAudioPlayer *)audioPlayer logInfo:(NSString *)line
{
    NSLog(@"%@", line);
}

@end
