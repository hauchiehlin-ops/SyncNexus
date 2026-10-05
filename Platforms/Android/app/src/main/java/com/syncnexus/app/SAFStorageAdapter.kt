package com.syncnexus.app

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.documentfile.provider.DocumentFile
import java.io.InputStream
import java.io.OutputStream

data class AndroidEndpoint(
    val id: String,
    val uriString: String,
    val displayName: String,
    val isRemovable: Boolean = false
)

/**
 * Android Storage Access Framework (SAF) 轉接器
 * 負責處理 DocumentTree URI 的授權持久化與檔案串流操作
 */
class SAFStorageAdapter(private val context: Context) {

    fun takePersistablePermission(uri: Uri) {
        val takeFlags = Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
        try {
            context.contentResolver.takePersistableUriPermission(uri, takeFlags)
        } catch (_: SecurityException) {
            // Already taken or not persistable
        }
    }

    fun getDocumentTree(uri: Uri): DocumentFile? {
        return DocumentFile.fromTreeUri(context, uri)
    }

    fun openInputStream(uri: Uri): InputStream? {
        return context.contentResolver.openInputStream(uri)
    }

    fun openOutputStream(uri: Uri): OutputStream? {
        return context.contentResolver.openOutputStream(uri, "wt")   // truncate: a shorter file must not keep the old tail
    }

    fun listFiles(treeUri: Uri): List<DocumentFile> {
        val root = getDocumentTree(treeUri) ?: return emptyList()
        return root.listFiles().toList()
    }
}
