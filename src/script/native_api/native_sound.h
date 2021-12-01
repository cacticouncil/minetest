#pragma once
#include "sound.h"
#include "gui/guiEngine.h"

class NativeApiSound
{
private:
	static s32 native_sound_play(
			const SimpleSoundSpec &spec,  GUIEngine* guiEngine, bool looped);
	static int native_sound_stop(GUIEngine *guiEngine, u32 handle);
};
