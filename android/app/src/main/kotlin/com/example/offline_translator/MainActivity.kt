package com.example.offline_translator

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
	private val CHANNEL = "offline_translator/argos"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"translate" -> {
					val args = call.arguments as? Map<*, *>
					val text = args?.get("text") as? String ?: ""
					val src = args?.get("src") as? String ?: "auto"
					val tgt = args?.get("tgt") as? String ?: "en"

					try {
						// Use reflection to call Chaquopy's Python API so the project
						// can build even before Chaquopy is added to Gradle.
						val pythonClass = Class.forName("com.chaquo.python.Python")
						val getInstance = pythonClass.getMethod("getInstance")
						val py = getInstance.invoke(null)
						val getModule = pythonClass.getMethod("getModule", String::class.java)
						val module = getModule.invoke(py, "argos_service")

						val moduleClass = module.javaClass
						val callAttr = moduleClass.getMethod("callAttr", String::class.java, Array<Any>::class.java)
						val argsArray: Array<Any> = arrayOf(text, src, tgt)
						val pyResult = callAttr.invoke(module, "translate", argsArray)
						result.success(pyResult?.toString() ?: "")
					} catch (e: Exception) {
						e.printStackTrace()
						// Fallback: return an echo-stub so Flutter side can be developed without Chaquopy
						result.success("[stub translation] $text")
					}
				}
				"init" -> {
					val args = call.arguments as? Map<*, *>
					val path = args?.get("models_path") as? String
					try {
						val pythonClass = Class.forName("com.chaquo.python.Python")
						val getInstance = pythonClass.getMethod("getInstance")
						val py = getInstance.invoke(null)
						val getModule = pythonClass.getMethod("getModule", String::class.java)
						val module = getModule.invoke(py, "argos_service")
						val moduleClass = module.javaClass
						val callAttr = moduleClass.getMethod("callAttr", String::class.java, Array<Any>::class.java)
						val argsArray: Array<Any> = if (path != null) arrayOf(path) else arrayOf()
						val pyResult = callAttr.invoke(module, "init", argsArray)
						result.success(pyResult?.toString() ?: "ok")
					} catch (e: Exception) {
						e.printStackTrace()
						result.success("error: ${e.message}")
					}
				}
				else -> result.notImplemented()
			}
		}
	}
}
