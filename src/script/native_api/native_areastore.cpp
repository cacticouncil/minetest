#include "native_areastore.h"
#include "util/areastore.h"
#include "filesys.h"
#include <fstream>
#include <tuple>

static std::tuple<bool, v3s16, v3s16, std::string> native_push_area(
		const Area *a, bool include_borders, bool include_data)
{
	std::tuple<bool, v3s16, v3s16, std::string> result;
	if (!include_borders && !include_data) {
		std::get<0>(result) = true;
		return result;
	}
	if (include_borders) {
		std::get<1>(result) = a->minedge;
		std::get<2>(result) = a->maxedge;
	}
	if (include_data) {
		std::get<3>(result) = a->data.c_str();
	}
	return result;
}

static std::map<u32, std::tuple<bool, v3s16, v3s16, std::string>> native_push_areas(
		const std::vector<Area *> &areas, bool include_borders, bool include_data)
{
	size_t cnt = areas.size();
	std::map<u32, std::tuple<bool, v3s16, v3s16, std::string>> result;
	for (size_t i = 0; i < cnt; i++) {
		// TODO: some sort of save for area to id?
		result[areas[i]->id] =
				native_push_area(areas[i], include_borders, include_data);
	}

	return result;
}

static std::tuple<bool, std::string> native_deserialization_helper(
		AreaStore *as, std::istream &is)
{
	std::tuple<bool, std::string> result;
	try {
		as->deserialize(is);
	} catch (const SerializationError &e) {
		std::get<0>(result) = false;
		std::get<1>(result) = e.what();
		return result;
	}
	std::get<0>(result) = true;
	return result;
}

std::tuple<bool, v3s16, v3s16, std::string> NativeAreaStore::native_get_area(
		Area *res, u32 id, bool include_borders, bool include_data)
{
	return native_push_area(res, include_borders, include_data);
}

std::map<u32, std::tuple<bool, v3s16, v3s16, std::string>>
NativeAreaStore::native_get_areas_for_pos(
		AreaStore *ast, v3s16 pos, bool include_borders, bool include_data)
{
	std::vector<Area *> res;

	ast->getAreasForPos(&res, pos);
	return native_push_areas(res, include_borders, include_data);
}

std::map<u32, std::tuple<bool, v3s16, v3s16, std::string>>
NativeAreaStore::native_get_areas_in_area(AreaStore *ast, v3s16 minedge, v3s16 maxedge,
		bool include_borders, bool include_data, bool accept_overlap)
{
	std::vector<Area *> res;

	ast->getAreasInArea(&res, minedge, maxedge, accept_overlap);
	return native_push_areas(res, include_borders, include_data);
}

int NativeAreaStore::native_insert_area(
		AreaStore *ast, v3s16 edge1, v3s16 edge2, std::string data, int *id)
{
	// believe these are minedge and maxedge based off of of origian lua index
	Area a(edge1, edge2);

	a.data = data;

	if (id != nullptr)
		a.id = *id;

	// Insert & assign a new ID if necessary
	if (!ast->insertArea(&a))
		return 0;

	return a.id;
}

int NativeAreaStore::native_reserve(AreaStore *ast, size_t count)
{
	ast->reserve(count);
	return 1;
}

int NativeAreaStore::native_remove_area(AreaStore *ast, u32 id)
{
	return ast->removeArea(id);
}

int NativeAreaStore::native_set_cache_params(
		AreaStore *ast, bool *enabled, u8 *block_radius, size_t *limit)
{
	ast->setCacheParams(*enabled, *block_radius, *limit);

	return 1;
}

std::string NativeAreaStore::native_to_string(AreaStore *ast)
{
	std::ostringstream os(std::ios_base::binary);
	ast->serialize(os);
	return os.str();
}

int NativeAreaStore::native_to_file(AreaStore *ast, std::string filename)
{
	std::ostringstream os(std::ios_base::binary);
	ast->serialize(os);

	return fs::safeWriteToFile(filename, os.str());
}

std::tuple<bool, std::string> NativeAreaStore::native_from_string(
		AreaStore *ast, std::string str)
{
	std::istringstream is(str, std::ios::binary);
	return native_deserialization_helper(ast, is);
}

std::tuple<bool, std::string> NativeAreaStore::native_from_file(
		AreaStore *ast, std::string filename)
{
	std::ifstream is(filename, std::ios::binary);
	return native_deserialization_helper(ast, is);
}
