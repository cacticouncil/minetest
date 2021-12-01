#include "native_sound.h"
#include "gui/guiEngine.h"
#include "script/cpp_api/s_base.h"

s32 NativeApiSound::native_sound_play(
		const SimpleSoundSpec &spec, GUIEngine *guiEngine, bool looped)
{
	return guiEngine->playSound(spec, looped);
}

int NativeApiSound::native_sound_stop(GUIEngine *guiEngine, u32 handle)
{
	guiEngine->stopSound(handle);
	return 1;
}