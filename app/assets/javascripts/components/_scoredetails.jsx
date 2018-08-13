var Scoredetails = React.createClass({
    render(){
      var over = this.props.details.game_over
        return(
            <div>
              <p> Id: {this.props.details.id} </p>
              <p> Point: {this.props.details.point} </p>
              <p> Point by frame: {JSON.stringify(this.props.details.point_by_frame)} </p>
              <p> Frame number: {this.props.details.point_by_frame.length} </p>
              <p> Game: { over==2 ? "Not Started" : over ? "Over" : "In progress" } </p>
            </div>
        )
    }
});
