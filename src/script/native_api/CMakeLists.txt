set(common_SCRIPT_NATIVE_API_SRCS
	${CMAKE_CURRENT_SOURCE_DIR}/native_item.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/native_areastore.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/native_particles.cpp
	PARENT_SCOPE)

set(client_SCRIPT_NATIVE_API_SRCS
	${CMAKE_CURRENT_SOURCE_DIR}/native_camera.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/native_client.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/native_particles_local.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/native_sound.cpp
	PARENT_SCOPE)
