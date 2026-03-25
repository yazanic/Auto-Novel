@echo off
REM #############################################################################
REM Deployment Script for Claude Code Novel Writing Tools (Windows)
REM This script deploys skills and agents from tools/ to .claude/ directory
REM #############################################################################

SETLOCAL EnableDelayedExpansion

REM Configuration
SET TOOLS_DIR=tools
SET CLAUDE_DIR=.claude
SET SKILLS_SOURCE=%TOOLS_DIR%\skills
SET AGENTS_SOURCE=%TOOLS_DIR%\agents
SET SKILLS_DEST=%CLAUDE_DIR%\skills
SET AGENTS_DEST=%CLAUDE_DIR%\agents

REM Skill names
SET SKILLS=auto-novel novel-planning novel-chapter

REM Agent names
SET AGENTS=novel-supervisor.md interstellar-novelist.md logic-reviewer.md

REM #############################################################################
REM Deployment Steps
REM #############################################################################

echo ========================================
echo Claude Code Novel Writing Tools - Deployment
echo ========================================
echo.

REM Step 1: Validate source directories
echo [STEP] Validating source directories...
IF NOT EXIST "%TOOLS_DIR%" (
    echo [ERROR] Directory '%TOOLS_DIR%' does not exist
    EXIT /B 1
)
IF NOT EXIST "%SKILLS_SOURCE%" (
    echo [ERROR] Directory '%SKILLS_SOURCE%' does not exist
    EXIT /B 1
)
IF NOT EXIST "%AGENTS_SOURCE%" (
    echo [ERROR] Directory '%AGENTS_SOURCE%' does not exist
    EXIT /B 1
)
echo [SUCCESS] Source directories validated
echo.

REM Step 2: Create .claude directory structure
echo [STEP] Creating .claude directory structure...
IF NOT EXIST "%CLAUDE_DIR%" (
    mkdir "%CLAUDE_DIR%"
    echo [SUCCESS] Created directory: %CLAUDE_DIR%
)
IF NOT EXIST "%SKILLS_DEST%" (
    mkdir "%SKILLS_DEST%"
    echo [SUCCESS] Created directory: %SKILLS_DEST%
)
IF NOT EXIST "%AGENTS_DEST%" (
    mkdir "%AGENTS_DEST%"
    echo [SUCCESS] Created directory: %AGENTS_DEST%
)
echo.

REM Step 3: Deploy skills
echo [STEP] Deploying skills...
FOR %%s IN (%SKILLS%) DO (
    SET skill_source=%SKILLS_SOURCE%\%%s
    SET skill_dest=%SKILLS_DEST%\%%s

    IF NOT EXIST "!skill_source!" (
        echo [ERROR] Skill source not found: !skill_source!
        EXIT /B 1
    )

    IF NOT EXIST "!skill_dest!" (
        mkdir "!skill_dest!"
    )

    IF EXIST "!skill_source!\SKILL.md" (
        copy /Y "!skill_source!\SKILL.md" "!skill_dest!\SKILL.md" >nul
        echo [SUCCESS] Deployed skill: %%s
    ) ELSE (
        echo [ERROR] SKILL.md not found in: !skill_source!
        EXIT /B 1
    )
)
echo.

REM Step 4: Deploy agents
echo [STEP] Deploying agents...
FOR %%a IN (%AGENTS%) DO (
    SET agent_source=%AGENTS_SOURCE%\%%a
    SET agent_dest=%AGENTS_DEST%\%%a

    IF NOT EXIST "!agent_source!" (
        echo [ERROR] Agent source not found: !agent_source!
        EXIT /B 1
    )

    copy /Y "!agent_source!" "!agent_dest!" >nul
    echo [SUCCESS] Deployed agent: %%a
)
echo.

REM Step 5: Verify deployment
echo [STEP] Verifying deployment...
SET deployment_success=1

REM Check skills
FOR %%s IN (%SKILLS%) DO (
    IF NOT EXIST "%SKILLS_DEST%\%%s\SKILL.md" (
        echo [ERROR] Verification failed: %SKILLS_DEST%\%%s\SKILL.md
        SET deployment_success=0
    )
)

REM Check agents
FOR %%a IN (%AGENTS%) DO (
    IF NOT EXIST "%AGENTS_DEST%\%%a" (
        echo [ERROR] Verification failed: %AGENTS_DEST%\%%a
        SET deployment_success=0
    )
)

IF !deployment_success! == 1 (
    echo [SUCCESS] All deployments verified successfully
) ELSE (
    echo [ERROR] Deployment verification failed
    EXIT /B 1
)
echo.

REM Step 6: Summary
echo ========================================
echo Deployment Summary
echo ========================================
echo.
echo Deployed Skills:
FOR %%s IN (%SKILLS%) DO (
    echo   - %%s
)
echo.
echo Deployed Agents:
FOR %%a IN (%AGENTS%) DO (
    echo   - %%a
)
echo.
echo [SUCCESS] Deployment completed successfully!
echo.
echo You can now use these skills and agents in Claude Code.
echo Skills: Invoke with /auto-novel, /novel-planning, /novel-chapter
echo Agents: Available in .claude\agents\
echo.

ENDLOCAL
