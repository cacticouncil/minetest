#pragma once
#include "irr_v3d.h"
#include <tuple>
#include <string>
#include <map>
#include "util/areastore.h"

class NativeAreaStore
{
private:
	static std::tuple<bool, v3s16, v3s16, std::string> native_get_area(
			Area *res, u32 id, bool include_borders, bool include_data);
	static std::map<u32, std::tuple<bool, v3s16, v3s16, std::string>>
	native_get_areas_for_pos(AreaStore *ast, v3s16 pos, bool include_borders,
			bool include_data);
	static std::map<u32, std::tuple<bool, v3s16, v3s16, std::string>>
	native_get_areas_in_area(AreaStore *ast, v3s16 minedge, v3s16 maxedge,
			bool include_borders, bool include_data, bool accept_overlap);
	static int native_insert_area(AreaStore *ast, v3s16 edge1, v3s16 edge2,
			std::string data, int *id = nullptr);
	static int native_reserve(AreaStore *ast, size_t count);
	static int native_remove_area(AreaStore *ast, u32 id);
	static int native_set_cache_params(AreaStore *ast, bool *enabled = nullptr,
			u8 *block_radius = nullptr, size_t *limit = nullptr);
	static std::string native_to_string(AreaStore *ast);
	static int native_to_file(AreaStore *ast, std::string filename);
	static std::tuple<bool, std::string> native_from_string(
			AreaStore *ast, std::string str);
	static std::tuple<bool, std::string> native_from_file(
			AreaStore *ast, std::string filename);
};
