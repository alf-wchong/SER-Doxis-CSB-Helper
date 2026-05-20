@groovy.transform.BaseScript com.ser.blueline.groovy.CSBScript enableFulltextRetrofitAgent

import com.ser.blueline.IDocument
import com.ser.blueline.IInformationObject
import com.ser.blueline.IQueryParameter
import de.ser.doxis4.agentserver.AgentExecutionResult
import de.ser.doxis4.agentserver.AgentServerReturnCodes
import org.slf4j.Logger
import org.slf4j.LoggerFactory

final Logger LOG = LoggerFactory.getLogger("agent.fulltext.retrofit")

/*
===========================================================================
CONFIGURATION (agent parameters)
===========================================================================

DMS_DB_SHORTNAME     mandatory
DOCUMENT_CLASS_ID    mandatory
BATCH_SIZE           optional, default 250
FULLTEXT_VALUE       optional, default "0"
ONLY_IF_EMPTY        optional, default true

Example:
DMS_DB_SHORTNAME  = PROD
DOCUMENT_CLASS_ID = 6eb14949-b69a-4560-bf4a-08318c09c587
BATCH_SIZE        = 250
FULLTEXT_VALUE    = 0
ONLY_IF_EMPTY     = true

===========================================================================
*/

final String dbName          = (DMS_DB_SHORTNAME ?: "").trim()
final String classId         = (DOCUMENT_CLASS_ID ?: "").trim()
final int batchSize          = (BATCH_SIZE ?: "250") as int
final String fulltextValue   = (FULLTEXT_VALUE ?: "0").trim()
final boolean onlyIfEmpty    = (ONLY_IF_EMPTY ?: "true").toBoolean()

if (!dbName || !classId) {

    LOG.error(
        "Mandatory configuration missing. dbName=<{}>, classId=<{}>",
        dbName,
        classId
    )

    return new AgentExecutionResult(
        AgentServerReturnCodes.RETURN_CODE_ERROR,
        "Missing mandatory configuration.",
        false,
        null
    )
}

String whereClause = """
TYPE = '${classId}'
""".trim()

if (onlyIfEmpty) {
    whereClause += " AND Fulltext IS NULL"
}

LOG.atInfo().log(
    "Starting retrofit. db=<{}>, class=<{}>, batchSize=<{}>, onlyIfEmpty=<{}>",
    dbName,
    classId,
    batchSize,
    onlyIfEmpty
)

def query = null

int processed = 0
int skipped = 0
int locked = 0
int failed = 0

try {

    query = ses.createQuery(dbName, whereClause, batchSize)

    query.currentVersionOnly = true

    IInformationObject[] results = query.results

    LOG.atDebug().log(
        "Search returned <{}> objects.",
        results?.length ?: 0
    )

    for (IInformationObject result : results) {

        IDocument doc = result?.doc

        if (doc == null) {
            skipped++
            continue
        }

        try {

            /*
             ==============================================================
             LOCK / CHECKOUT HANDLING
             ==============================================================
            */

            def lockInfo = null

            try {

                lockInfo = doc.checkout()

                if (lockInfo == null ||
                    lockInfo.isForeign() ||
                    !lockInfo.isCreatedNow()) {

                    locked++

                    LOG.atWarn().log(
                        "Document currently locked. docId=<{}>",
                        doc.ID
                    )

                    continue
                }

                String currentValue = doc["Fulltext"]

                if (onlyIfEmpty &&
                    currentValue != null &&
                    currentValue.trim().length() > 0) {

                    skipped++

                    LOG.atDebug().log(
                        "Skipping already configured document <{}>",
                        doc.ID
                    )

                    continue
                }

                /*
                 ==========================================================
                 APPLY FULLTEXT CONFIGURATION
                 ==========================================================
                */

                doc["Fulltext"] = fulltextValue

                doc.commit()

                processed++

                LOG.atInfo().log(
                    "Enabled fulltext indexing for document <{}>",
                    doc.ID
                )

            } finally {

                try {

                    if (lockInfo != null &&
                        !lockInfo.isForeign() &&
                        lockInfo.isCreatedNow()) {

                        lockInfo.unlock()
                    }

                } catch (Exception unlockEx) {

                    LOG.atWarn()
                        .setCause(unlockEx)
                        .log(
                            "Failed to unlock document <{}>",
                            doc?.ID
                        )
                }
            }

        } catch (Exception objectEx) {

            failed++

            LOG.atError()
                .setCause(objectEx)
                .log(
                    "Failed processing document <{}>",
                    doc?.ID
                )
        }
    }

    String message = String.format(
        "Retrofit completed. processed=%d skipped=%d locked=%d failed=%d",
        processed,
        skipped,
        locked,
        failed
    )

    /*
     =====================================================================
     RESULT EVALUATION
     =====================================================================
    */

    if (failed > 0) {

        return new AgentExecutionResult(
            AgentServerReturnCodes.RETURN_CODE_ERROR_WARN,
            message,
            true,
            null
        )
    }

    if (locked > 0) {

        /*
         Locked objects are transient conditions.
         Allow restart/retry handling.
        */

        return new AgentExecutionResult(
            AgentServerReturnCodes.RETURN_CODE_SUCCESS_WARN,
            message,
            true,
            null
        )
    }

    return new AgentExecutionResult(
        AgentServerReturnCodes.RETURN_CODE_SUCCESS,
        message,
        false,
        null
    )

} catch (Exception e) {

    LOG.atError()
        .setCause(e)
        .log(
            "Fatal retrofit failure in job <{}>",
            agentJobId
        )

    return new AgentExecutionResult(
        AgentServerReturnCodes.RETURN_CODE_ERROR,
        "Fatal retrofit failure: ${e.message}",
        true,
        null
    )

} finally {

    /*
     =====================================================================
     RELEASE QUERY RESOURCES
     =====================================================================
    */

    try {

        if (query instanceof IQueryParameter) {
            query.close()
        }

    } catch (Exception closeEx) {

        LOG.atWarn()
            .setCause(closeEx)
            .log("Failed closing query resources.")
    }
}
