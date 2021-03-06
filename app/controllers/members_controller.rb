class MembersController < ApplicationController
  before_filter :load_group

  def create
    member = @group.members.build(params[:member])
    if member.save
      flash[:message] = "#{member.name} added!"
    else
      flash[:error] = "Error!  Member not added!"
    end
    redirect_to(group_settings_url(@group))
  end
end
  