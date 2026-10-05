local HttpService = game:GetService("HttpService")
local req = request or http_request or httprequest or (syn and syn.request)

local CoreModule = {}

function CoreModule.GetEmotes()
    local emotesTable = {}
    
    if not req then
        warn("[EmoteCore] HTTP request function (request/http_request/httprequest) is not supported in this executor.")
        return emotesTable
    end

    local apiUrl = "https://api.github.com/repos/dcus-official/Shared/contents/Emotes"
    
    local success, response = pcall(function()
        return req({
            Url = apiUrl,
            Method = "GET"
        })
    end)
    
    if not success or not response then
        warn("[EmoteCore] Failed to fetch emotes list from GitHub.")
        return emotesTable
    end
    
    if response.StatusCode ~= 200 then
        warn("[EmoteCore] GitHub API Error (" .. tostring(response.StatusCode) .. "): " .. tostring(response.Body))
        return emotesTable
    end
    
    local decodeSuccess, decoded = pcall(function()
        return HttpService:JSONDecode(response.Body)
    end)
    
    if not decodeSuccess or type(decoded) ~= "table" then
        warn("[EmoteCore] Failed to decode API response.")
        return emotesTable
    end

    for _, fileInfo in ipairs(decoded) do
        if fileInfo.type == "file" and fileInfo.name:match("%.lua$") then
            local emoteName = fileInfo.name:gsub("%.lua$", "")
            local downloadUrl = fileInfo.download_url
            
            local fileSuccess, fileResponse = pcall(function()
                return req({
                    Url = downloadUrl,
                    Method = "GET"
                })
            end)
            
            if fileSuccess and fileResponse and fileResponse.StatusCode == 200 then
                emotesTable[emoteName] = fileResponse.Body
            else
                warn("[EmoteCore] Failed to download emote: " .. emoteName)
            end
        end
    end
    
    return emotesTable
end

return CoreModule
