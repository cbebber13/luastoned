local private = {};
local public = {};
aeslua = public;
aeslua.private = private

local subfiles = {
	"util.lua",
	"buffer.lua",
	"gf.lua",
	"aes.lua",
	"ciphermode.lua",
}
debug.sethook()
for k,sub in pairs(subfiles) do
	RunString(file.Read("../lua/vgui/luastoned/aeslua/"..sub))
end	

local cipher = aeslua.ciphermode
local aesutil = aeslua.util

--
-- Simple API for encrypting strings.
--

public.AES128 = 16;
public.AES192 = 24;
public.AES256 = 32;

public.ECBMODE = 1;
public.CBCMODE = 2;
public.OFBMODE = 3;
public.CFBMODE = 4;

function private.pwToKey(password, keyLength)
    local padLength = keyLength;
    if (keyLength == public.AES192) then
        padLength = 32;
    end
    
    if (padLength > #password) then
        local postfix = "";
        for i = 1,padLength - #password do
            postfix = postfix .. string.char(0);
        end
        password = password .. postfix;
    else
        password = string.sub(password, 1, padLength);
    end
    
    local pwBytes = {string.byte(password,1,#password)};
    password = cipher.encryptString(pwBytes, password, cipher.encryptCBC);
    
    password = string.sub(password, 1, keyLength);
   
    return {string.byte(password,1,#password)};
end

--
-- Encrypts string data with password password.
-- password  - the encryption key is generated from this string
-- data      - string to encrypt (must not be too large)
-- keyLength - length of aes key: 128(default), 192 or 256 Bit
-- mode      - mode of encryption: ecb, cbc(default), ofb, cfb 
--
-- mode and keyLength must be the same for encryption and decryption.
--
function public.encrypt(password, data, keyLength, mode)
	assert(password ~= nil, "Empty password.");
	assert(data ~= nil, "Empty data.");
	 
    local mode = mode or public.CBCMODE;
    local keyLength = keyLength or public.AES128;

    local key = private.pwToKey(password, keyLength);

    local paddedData = aesutil.padByteString(data);
    
    if (mode == public.ECBMODE) then
        return cipher.encryptString(key, paddedData, cipher.encryptECB);
    elseif (mode == public.CBCMODE) then
        return cipher.encryptString(key, paddedData, cipher.encryptCBC);
    elseif (mode == public.OFBMODE) then
        return cipher.encryptString(key, paddedData, cipher.encryptOFB);
    elseif (mode == public.CFBMODE) then
        return cipher.encryptString(key, paddedData, cipher.encryptCFB);
    else
        return nil;
    end
end




--
-- Decrypts string data with password password.
-- password  - the decryption key is generated from this string
-- data      - string to encrypt
-- keyLength - length of aes key: 128(default), 192 or 256 Bit
-- mode      - mode of decryption: ecb, cbc(default), ofb, cfb 
--
-- mode and keyLength must be the same for encryption and decryption.
--
function public.decrypt(password, data, keyLength, mode)
    local mode = mode or public.CBCMODE;
    local keyLength = keyLength or public.AES128;

    local key = private.pwToKey(password, keyLength);
    
    local plain;
    if (mode == public.ECBMODE) then
        plain = cipher.decryptString(key, data, cipher.decryptECB);
    elseif (mode == public.CBCMODE) then
        plain = cipher.decryptString(key, data, cipher.decryptCBC);
    elseif (mode == public.OFBMODE) then
        plain = cipher.decryptString(key, data, cipher.decryptOFB);
    elseif (mode == public.CFBMODE) then
        plain = cipher.decryptString(key, data, cipher.decryptCFB);
    end
    
    result = aesutil.unpadByteString(plain);
    
    if (result == nil) then
        return nil;
    end
    
    return result;
end
