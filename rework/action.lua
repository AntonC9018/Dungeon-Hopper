local Action = class('Action')

function Action:__constuct(v, actor, code, ...)
    self.dir = v
    self.actor = actor
    self.code = code
    self.args = ...
end

return Action