local base_url = "https://discord.com/api/v10"

local Endpoints = {}

function Endpoints.CHANNEL(channel_id)
    return base_url.."/channels/"..channel_id
end

function Endpoints.CHANNEL_MESSAGES(channel_id)
    return base_url.."/channels/"..channel_id.."/messages"
end

function Endpoints.GUILD(guild_id)
    return base_url.."/guilds/"..guild_id
end

function Endpoints.MEMBER(guild_id, member_id)
    return base_url.."/guilds/"..guild_id.."/members/"..member_id
end

function Endpoints.USER(user_id)
    return base_url.."/users/"..user_id
end

function Endpoints.ROLE(guild_id, role_id)
    return base_url.."/guilds/"..guild_id.."/roles/"..role_id
end

function Endpoints.EMBED(channel_id, message_id)
    return base_url.."/channels/"..channel_id.."/messages/"..message_id
end

return Endpoints